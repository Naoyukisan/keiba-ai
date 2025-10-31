# db/migrate/20251031193000_fix_messages_user_nullable_and_fk.rb
class FixMessagesUserNullableAndFk < ActiveRecord::Migration[8.0]
  def up
    # 1) user_id を NULL 許可へ
    change_column_null :messages, :user_id, true

    # 2) 既存 FK を外す（列を明示）
    if foreign_key_exists?(:messages, :users, column: :user_id)
      remove_foreign_key :messages, column: :user_id
    end

    # 3) ON DELETE SET NULL で付け直し
    add_foreign_key :messages, :users, column: :user_id, on_delete: :nullify

    # 4) 念のため index（無ければ）
    add_index :messages, :user_id unless index_exists?(:messages, :user_id)
  end

  def down
    # 逆戻し（必要なら）。まず FK を通常に戻す
    if foreign_key_exists?(:messages, :users, column: :user_id)
      remove_foreign_key :messages, column: :user_id
    end
    add_foreign_key :messages, :users, column: :user_id # デフォルト: RESTRICT

    # ※ NOT NULL に戻すには、事前に NULL 行を片付けてから実施してください
    # change_column_null :messages, :user_id, false
  end
end
