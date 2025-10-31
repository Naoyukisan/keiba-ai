# db/migrate/20251031194500_add_user_to_blogs.rb
class AddUserToBlogs < ActiveRecord::Migration[8.0]
  def up
    # 1) blogs に user_id（NULL許可）を追加
    add_reference :blogs, :user, null: true, index: true

    # 2) 既存に余計なFKが無い想定だが、念のため外して付け直す処理を安全に
    if foreign_key_exists?(:blogs, :users, column: :user_id)
      remove_foreign_key :blogs, column: :user_id
    end

    # 3) 親ユーザー削除時に SET NULL となるFKを付与
    add_foreign_key :blogs, :users, column: :user_id, on_delete: :nullify
  end

  def down
    # 逆マイグレーション：FKを外してからカラムを削除
    remove_foreign_key :blogs, column: :user_id if foreign_key_exists?(:blogs, :users, column: :user_id)
    remove_reference :blogs, :user, index: true
  end
end
