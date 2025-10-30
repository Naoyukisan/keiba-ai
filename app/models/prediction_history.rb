class PredictionHistory < ApplicationRecord
  # 既存データ救済のため optional: true にしておきつつ、
  # 新規作成時（create）のみ user 必須にします。
  belongs_to :user, optional: true
  validates :user, presence: true, on: :create
end
