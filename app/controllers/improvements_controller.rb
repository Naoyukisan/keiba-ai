# app/controllers/improvements_controller.rb
class ImprovementsController < ApplicationController
  def new
    @current_method   = CurrentPredictionMethodFetcher.call
    @predicted_result = ""
    @actual_result    = ""
    @improved_method  = nil
  end

  def create
    @current_method   = params[:current_method].presence || CurrentPredictionMethodFetcher.call
    @predicted_result = params[:predicted_result].to_s
    @actual_result    = params[:actual_result].to_s

    client = GeminiClient.new
    prompt = build_improvement_prompt(@current_method, @predicted_result, @actual_result)
    @improved_method = client.generate_text(prompt)

    render :new
  rescue => e
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_entity
  end

  # ルート: POST /improvements/apply （apply_improvements_path）
  def apply
    body = params[:improved_method].to_s
    return redirect_to(new_improvement_path, alert: "改善後の予想方法が空です") if body.blank?

    pm = PredictionMethod.create!(
      name:   "v#{Time.current.strftime('%Y%m%d%H%M')}",
      body:   body,
      active: false
    )
    PredictionMethod.activate!(pm.id)
    redirect_to new_improvement_path, notice: "改善案を適用しました。以後の予想に使います。"
  rescue => e
    redirect_to new_improvement_path, alert: "適用に失敗しました: #{e.message}"
  end

  private

  def build_improvement_prompt(current, predicted, actual)
    <<~PROMPT.strip
      あなたは競馬予想の改善コーチです。
      下記は現在の予想方法で予想した直近の予想結果と実際の結果である。
      差分を踏まえて「改善後の予想方法」を出力してほしい。
      尚 出力要件に記載されたセクションの構成は崩さないこと。
      出力方法は「改善後の予想方法」の文章のみとすること。

      # 現在の予想方法
      #{current}

      # 直近の予想結果
      #{predicted}

      # 実際の結果
      #{actual}
    PROMPT
  end
end
