class CreatePredictionHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :prediction_histories do |t|
      t.string :race_name
      t.date :date
      t.text :result

      t.timestamps
    end
  end
end
