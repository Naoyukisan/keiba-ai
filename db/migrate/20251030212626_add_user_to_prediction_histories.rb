# db/migrate/20251030212626_add_user_to_prediction_histories.rb
class AddUserToPredictionHistories < ActiveRecord::Migration[8.0]
  def change
    # 1) カラムが無ければ add_reference（index, FK 付き）
    unless column_exists?(:prediction_histories, :user_id)
      add_reference :prediction_histories, :user, null: true, index: true, foreign_key: true
    end

    # 2) index が無ければ追加
    unless index_exists?(:prediction_histories, :user_id)
      add_index :prediction_histories, :user_id
    end

    # 3) 外部キーが無ければ追加
    unless foreign_key_exists?(:prediction_histories, :users, column: :user_id)
      add_foreign_key :prediction_histories, :users, column: :user_id
    end
  end
end
