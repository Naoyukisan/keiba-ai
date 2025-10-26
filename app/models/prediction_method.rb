# app/models/prediction_method.rb
class PredictionMethod < ApplicationRecord
  scope :current, -> { where(active: true).order(id: :desc).first }
  scope :ordered, -> { order(id: :desc) }

  def self.activate!(id)
    transaction do
      update_all(active: false)
      find(id).update!(active: true)
    end
  end

  def self.activate_previous!
    cur  = current
    prev = where("id < ?", cur&.id || 10**9).order(id: :desc).first
    prev ||= ordered.offset(1).first
    raise ActiveRecord::RecordNotFound, "前の予想方法がありません" unless prev

    transaction do
      update_all(active: false)
      prev.update!(active: true)
    end
    prev
  end
end
