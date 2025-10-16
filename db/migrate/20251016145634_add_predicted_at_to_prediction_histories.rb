class AddPredictedAtToPredictionHistories < ActiveRecord::Migration[8.0]
  def change
    add_column :prediction_histories, :predicted_at, :datetime
  end
end
