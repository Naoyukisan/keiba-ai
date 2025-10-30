# app/models/prediction_history.rb
class PredictionHistory < ApplicationRecord
  belongs_to :user, optional: true
  # 他の関連やバリデーションがあればここに
end
