class CurrentPredictionMethodFetcher
  class << self
    # 現在有効な予想方法（なければ最新 or 空文字）を返す
    def call
      PredictionMethod.where(active: true).limit(1).pick(:body).to_s.presence ||
        PredictionMethod.order(updated_at: :desc).limit(1).pick(:body).to_s
    end
  end
end
