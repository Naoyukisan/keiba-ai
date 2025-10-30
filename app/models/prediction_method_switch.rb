# app/models/prediction_method_switch.rb
class PredictionMethodSwitch < ApplicationRecord
  belongs_to :prediction_method
  # 切替履歴は単純に「有効にしたID」と「時刻」だけを残す
end
