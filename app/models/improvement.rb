class Improvement < ApplicationRecord
  belongs_to :user, optional: true
  validates :user, presence: true, on: :create
end
