# db/migrate/20251031000000_change_user_foreign_keys_to_nullify.rb
class ChangeUserForeignKeysToNullify < ActiveRecord::Migration[8.0]
  def up
    # --- messages.user_id を NULL 許可に ---
    if column_exists?(:messages, :user_id)
      change_column_null :messages, :user_id, true
    end

    # 既存の外部キーを一旦外す（存在する場合のみ）
    if foreign_key_exists?(:messages, :users)
      remove_foreign_key :messages, :users
    end

    # ON DELETE SET NULL で付け直す
    add_foreign_key :messages, :users, on_delete: :nullify

    # 念のためインデックスが無ければ付与
    unless index_exists?(:messages, :user_id)
      add_index :messages, :user_id
    end
  end

  def down
    # もとに戻す場合（ON DELETE RESTRICT 相当）
    if foreign_key_exists?(:messages, :users)
      remove_foreign_key :messages, :users
    end
    add_foreign_key :messages, :users # on_delete なし = デフォルト（restrict）

    # NULL 不可に戻す場合は適宜データを埋めてからにしてください
    # change_column_null :messages, :user_id, false
  end
end
