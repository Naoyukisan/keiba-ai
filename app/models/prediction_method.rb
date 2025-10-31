# app/models/prediction_method.rb
class PredictionMethod < ApplicationRecord
  # === テスト互換: enabled <-> active を一致させる ===
  # alias_attribute は reader/writer 両方を用意するので
  # mass-assignment（Strong Parameters 経由）でも :enabled が使える
  alias_attribute :enabled, :active

  # === バリデーション ===
  validates :name, presence: true
  validates :body, presence: true

  # === スコープ ===
  scope :enabled, -> { where(active: true) } # ← テストでの「.enabled」に対応
  scope :current, -> { where(active: true).order(updated_at: :desc).first }

  # === 切り替え系ユースケース ===
  def self.activate!(target_id)
    pm = find(target_id)
    transaction do
      if column_names.include?("active")
        where.not(id: pm.id).update_all(active: false, activated_at: nil)
        pm.update!(active: true, activated_at: Time.current)
      end
      PredictionMethodSwitch.create!(prediction_method_id: pm.id)
    end
    pm
  end

  def self.activate_previous!
    last_two = PredictionMethodSwitch.order(created_at: :desc).limit(2).to_a
    raise ActiveRecord::RecordNotFound, "直前に戻せる履歴がありません。" if last_two.size < 2
    prev = find(last_two.second.prediction_method_id)
    activate!(prev.id)
  end
end
