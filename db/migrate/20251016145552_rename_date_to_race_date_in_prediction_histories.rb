# db/migrate/xxxxxx_rename_date_to_race_date_in_prediction_histories.rb
class RenameDateToRaceDateInPredictionHistories < ActiveRecord::Migration[8.0]
  def change
    rename_column :prediction_histories, :date, :race_date
  end
end
