class CreatePredictionMethods < ActiveRecord::Migration[8.0]
  def change
    create_table :prediction_methods do |t|
      t.string  :name, null: false, default: "default"
      t.text    :body, null: false
      t.boolean :active, null: false, default: false

      t.timestamps
    end
    add_index :prediction_methods, :active
  end
end