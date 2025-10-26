# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.0]
  def up
    # すでに users テーブルが存在している前提で、重複エラーを防ぐ
    change_table :users, bulk: true do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: "" unless column_exists?(:users, :email)
      t.string :encrypted_password, null: false, default: "" unless column_exists?(:users, :encrypted_password)

      ## Recoverable
      t.string   :reset_password_token unless column_exists?(:users, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:users, :reset_password_sent_at)

      ## Rememberable
      t.datetime :remember_created_at unless column_exists?(:users, :remember_created_at)

      ## Trackable（必要なら解除）
      # unless column_exists?(:users, :sign_in_count)
      #   t.integer  :sign_in_count, default: 0, null: false
      #   t.datetime :current_sign_in_at
      #   t.datetime :last_sign_in_at
      #   t.string   :current_sign_in_ip
      #   t.string   :last_sign_in_ip
      # end

      ## Confirmable / Lockable は使う場合のみ追加
    end

    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
  end

  def down
    # 元に戻す処理（存在チェック付き）
    remove_index  :users, :email if index_exists?(:users, :email)
    remove_index  :users, :reset_password_token if index_exists?(:users, :reset_password_token)

    remove_column :users, :reset_password_token if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at if column_exists?(:users, :remember_created_at)
    remove_column :users, :encrypted_password if column_exists?(:users, :encrypted_password)
    remove_column :users, :email if column_exists?(:users, :email)
  end
end
