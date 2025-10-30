# app/controllers/gemini_controller.rb
class GeminiController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_method, only: [:new, :create]

  def new; end

  def create
    @answer = nil
    attrs   = gemini_params

    # ✅ 必須条件は「レース名だけ」
    if attrs[:race_name].to_s.strip.blank?
      flash.now[:alert] = "レース名を入力してください。"
      return render :new, status: :unprocessable_entity
    end

    prompt = build_prompt(attrs)
    Rails.logger.info("[GEMINI#create] prompt_bytes=#{prompt.bytesize}")

    begin
      client = GeminiClient.new
      raw    = client.generate_text(prompt)
      @answer = extract_text(raw)
      Rails.logger.info("[GEMINI#create] raw_class=#{raw.class} answer_bytes=#{@answer.to_s.bytesize}")
    rescue => e
      Rails.logger.error("[GEMINI#create][AI ERROR] #{e.class}: #{e.message}")
      flash.now[:alert] = "予想の生成に失敗しました。しばらくしてから再度お試しください。"
      return render :new, status: :unprocessable_entity
    end

    if @answer.blank?
      flash.now[:alert] = "AIから有効な予想結果が返りませんでした。（ネットワーク・APIキー・モデル応答形式をご確認ください）"
      return render :new, status: :unprocessable_entity
    end

    history = PredictionHistory.new(
      race_name:    attrs[:race_name],
      race_date:    attrs[:date],
      predicted_at: Time.current,
      result:       @answer
    )
    history.user = current_user

    unless history.save
      Rails.logger.error("[GEMINI#create] validation_errors=#{history.errors.full_messages}")
      flash.now[:alert] = "履歴の保存に失敗しました: #{history.errors.full_messages.join(', ')}"
      return render :new, status: :unprocessable_entity
    end

    render :new, status: :ok
  end

  private

  def set_current_method
    @current_method = CurrentPredictionMethodFetcher.call
  end

  def gemini_params
    params
      .permit(:race_name, :date, :time, :place, :round, :class_name, :distance, :race_details)
      .to_h.symbolize_keys
  end

  # —— SDK差異に備えてテキストを抽出
  def extract_text(raw)
    return "" if raw.nil?
    return raw if raw.is_a?(String)

    data = raw.respond_to?(:to_h) ? raw.to_h : raw rescue raw
    if data.is_a?(Hash)
      return data[:text] || data["text"] ||
             dig_s(data, :output, :text) ||
             dig_s(data, "output", "text") ||
             dig_s(data, :choices, 0, :text) ||
             dig_s(data, "choices", 0, "text") ||
             dig_s(data, :candidates, 0, :content, :parts, 0, :text) ||
             dig_s(data, "candidates", 0, "content", "parts", 0, "text") ||
             data.to_s
    end
    raw.to_s
  end

  def dig_s(h, *keys)
    keys.reduce(h) { |acc, k|
      if acc.is_a?(Hash)
        acc[k] || acc[k.to_s] || acc[k.to_sym]
      elsif acc.is_a?(Array) && k.is_a?(Integer)
        acc[k]
      else
        nil
      end
    }.to_s
  end

  # —— レース名だけでも予想を生成できるプロンプト
  def build_prompt(h)
    weights = { perf: 40, pedigree: 20, cond: 40 }
    method_text = PredictionMethod.where(active: true).first&.body.to_s
    f = ->(v, fb = "-") { v.to_s.presence || fb }

    details = h[:race_details].to_s.strip
    details_present = details.present?

    # 出力仕様（既存版が長い場合は適宜差し替えてOK）
    output_spec = <<~SPEC
      # 出力要件（この順序・この見出し・このレイアウトを厳守）
      1) 「◇順位予想」セクション：
        ...(既存のまま)...
    SPEC

    method_fallback = <<~FALLBACK
      （参考：方法が未登録のため簡易ルールを適用）
      - 評価軸：実績・血統・調子。配点は方法に応じて適切に設定し、合計点と順位表の整合を保つこと。
    FALLBACK

    strict_rule =
      if details_present
        <<~R1
          # 厳格ルール（データの使い方）
          - 以降に与える「レース情報詳細（race_details）」を唯一の出走馬・オッズ等の情報源として使用してください。
          - 入力に存在しない馬名・馬番・数値は絶対に作らないでください。情報が無い項目は「不明」と表記してください。
          - 外部検索や一般知識による補完は禁止です。
        R1
      else
        <<~R2
          # 厳格ルール（データの使い方）
          - レース名以外の詳細は与えません。一般的な傾向・定番のファクター（実績・血統・調子など）に基づき、仮説として予想を構成してください。
          - 実在する出走馬の確定情報が無い前提で、固有名は「想定候補」として扱い、不確実性を明記してください。
          - 断定を避け、根拠と不確実性のバランスを明確に示してください。
        R2
      end

    details_block =
      if details_present
        <<~DTS
          # 入力（レース情報詳細 / race_details）
          以下のテキストブロックだけを根拠にしてください。改行・タブなどのレイアウトを保持して読み取ってください。
          ```
          #{details}
          ```
        DTS
      else
        "# 入力（レース情報詳細 / race_details）\n（詳細なし：レース名のみ）"
      end

    <<~PROMPT.strip
      あなたは競馬の予想ライターです。以下の入力を使い、**指定した構成とフォーマットだけ**で出力してください。
      余計な前置き・注意書き・自己言及は一切禁止です。日本語で書いてください。

      # 予想方法（この節の規則は最優先で厳守）
      #{method_text.presence || method_fallback}

      #{strict_rule}

      # 入力（レース情報のメタ）
      - レース名: #{f.(h[:race_name])}
      - 日付: #{f.(h[:date])} #{f.(h[:time])}
      - 競馬場: #{f.(h[:place])}
      - ラウンド: #{f.(h[:round])}
      - クラス: #{f.(h[:class_name])}
      - 距離: #{f.(h[:distance])}
      （重み付け：実績#{weights[:perf]}点、血統#{weights[:pedigree]}点、調子#{weights[:cond]}点）

      #{details_block}

      #{output_spec}
    PROMPT
  end
end
