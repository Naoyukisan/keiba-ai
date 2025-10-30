# db/migrate/20251031020000_fix_user_fk_nullify_bulk.rb
class FixUserFkNullifyBulk < ActiveRecord::Migration[8.0]
  # ↓ 監査タスクの出力を見て、犯人をここに列挙してください
  TARGETS = [
    # 例:
    # { table: :improvements, column: :user_id },
    # { table: :histories,    column: :user_id },
    # { table: :messages,     column: :user_id },
    # { table: :blogs,        column: :user_id },
    # { table: :rooms,        column: :owner_id }, # 列名が user_id でない場合の例
  ]

  def up
    TARGETS.each do |t|
      tbl = t[:table]
      col = t[:column]

      next unless column_exists?(tbl, col, :bigint)

      # 1) NULL許可
      change_column_null tbl, col, true

      # 2) 既存FKを外す（存在すれば）
      if foreign_key_exists?(tbl, :users, column: col)
        remove_foreign_key tbl, column: col
      end

      # 3) ON DELETE SET NULL で付け直し
      add_foreign_key tbl, :users, column: col, on_delete: :nullify

      # 4) インデックス（なければ張る）
      add_index tbl, col unless index_exists?(tbl, col)
    end
  end

  def down
    TARGETS.each do |t|
      tbl = t[:table]
      col = t[:column]
      next unless column_exists?(tbl, col, :bigint)

      if foreign_key_exists?(tbl, :users, column: col)
        remove_foreign_key tbl, column: col
      end
      add_foreign_key tbl, :users, column: col # デフォルト: RESTRICT
      change_column_null tbl, col, false
    end
  end
end
