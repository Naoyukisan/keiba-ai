# app/controllers/gemini_controller.rb
class GeminiController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_method, only: [:new, :create]

  def new; end

  def create
    @answer = nil
    attrs   = gemini_params

    # 必須チェック（最低限 race_details は欲しい想定）
    if attrs.values.all?(&:blank?) || attrs[:race_details].to_s.strip.blank?
      flash.now[:alert] = "入力が不足しています。フォームに値を入れてください。"
      render :new, status: :unprocessable_content and return
    end

    # プロンプト生成
    prompt = build_prompt(attrs)
    if prompt.blank?
      flash.now[:alert] = "レース情報（詳細）が不足しています。"
      render :new, status: :unprocessable_content and return
    end

    # 予想生成（外部呼び出しは明示的に囲む）
    begin
      client  = GeminiClient.new
      @answer = client.generate_text(prompt)
    rescue => e
      Rails.logger.error("[GEMINI#create] #{e.class}: #{e.message}")
      flash.now[:alert] = "予想の生成に失敗しました。しばらくしてから再度お試しください。"
      render :new, status: :unprocessable_content and return
    end

    # 履歴保存（!を避け、失敗は画面に出す）
    history = PredictionHistory.new(
      race_name:    attrs[:race_name],
      race_date:    attrs[:date],
      predicted_at: Time.current,
      result:       @answer
    )

    unless history.save
      Rails.logger.error("[GEMINI#create] validation_errors=#{history.errors.full_messages}")
      flash.now[:alert] = "履歴の保存に失敗しました: #{history.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_content and return
    end

    # 正常系は new を1回だけ描画
    render :new, status: :ok and return
  end

  private

  def set_current_method
    @current_method = CurrentPredictionMethodFetcher.call
  end

  # パラメータはトップレベルで届いている（require(:gemini) は使わない）
  def gemini_params
    params
      .permit(:race_name, :date, :time, :place, :round, :class_name, :distance, :race_details)
      .to_h
      .symbolize_keys
  end

  def build_prompt(h)
    weights = { perf: 40, pedigree: 20, cond: 40 }
    method_text = PredictionMethod.where(active: true).first&.body.to_s
    f = ->(v, fallback = "-") { v.to_s.presence || fallback }

    # race_details が空なら nil 返却（呼び出し側で早期リターンする）
    return nil if h[:race_details].to_s.strip.blank?

    output_spec = <<~SPEC
      # 出力要件（この順序・この見出し・このレイアウトを厳守）
      1) 「◇順位予想」セクション：
        ...(省略・現状のまま)...
    SPEC

    method_fallback = <<~FALLBACK
      （参考：方法が未登録のため簡易ルールを適用）
      - 評価軸：実績・血統・調子。配点は方法に応じて適切に設定し、合計点と順位表の整合を保つこと。
    FALLBACK

    <<~PROMPT.strip
      あなたは競馬の予想ライターです。以下の入力を使い、**指定した構成とフォーマットだけ**で出力してください。
      余計な前置き・注意書き・自己言及は一切禁止です。日本語で書いてください。

      # 予想方法（この節の規則は最優先で厳守）
      #{method_text.presence || method_fallback}

      # 厳格ルール（データの使い方）
      - 以降に与える「レース情報詳細（race_details）」を**唯一の出走馬・オッズ等の情報源**として使用してください。
      - 入力に存在しない馬名・馬番・数値は**絶対に作らない**でください。情報が無い項目は「不明」と表記してください。
      - 外部検索や一般知識による補完は禁止です。

      # 入力（レース情報）
      - レース名: #{f.(h[:race_name])}
      - 日付: #{f.(h[:date])} #{f.(h[:time])}
      - 競馬場: #{f.(h[:place])}
      - ラウンド: #{f.(h[:round])}
      - クラス: #{f.(h[:class_name])}
      - 距離: #{f.(h[:distance])}
      （重み付け：実績#{weights[:perf]}点、血統#{weights[:pedigree]}点、調子#{weights[:cond]}点）

      # 入力（レース情報詳細 / race_details）
      以下のテキストブロックだけを根拠にしてください。改行・タブなどのレイアウトを保持して読み取ってください。
      ```
      #{h[:race_details].to_s}
      ```

      #{output_spec}
    PROMPT
  end
end
