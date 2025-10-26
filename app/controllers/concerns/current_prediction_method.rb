module CurrentPredictionMethod
  extend ActiveSupport::Concern

  private

  def set_current_method
    # ▼ここは既存実装に合わせてください（ImprovementsController の実装をそのまま移植）
    # 例）PredictionMethod モデルに current フラグやステータスがある想定
    @current_method =
      PredictionMethod.where(active: true).order(updated_at: :desc).pick(:body) ||
      PredictionMethod.order(updated_at: :desc).pick(:body) ||
      ""
  end
end
