# db/migrate/XXXXXXXXXXXXXX_create_prediction_method_switches.rb
class CreatePredictionMethodSwitches < ActiveRecord::Migration[7.1]
  def change
    create_table :prediction_method_switches do |t|
      t.references :prediction_method, null: false, foreign_key: true
      t.timestamps
    end

    add_index :prediction_method_switches, :created_at
  end
end
