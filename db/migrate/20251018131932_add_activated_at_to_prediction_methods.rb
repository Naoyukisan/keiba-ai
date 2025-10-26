class AddActivatedAtToPredictionMethods < ActiveRecord::Migration[8.0]
  def change
    add_column :prediction_methods, :activated_at, :datetime
  end
end
