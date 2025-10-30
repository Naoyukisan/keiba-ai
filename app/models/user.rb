# app/models/user.rb
class User < ApplicationRecord
  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :prediction_histories, dependent: :nullify

  # ▼ ここを :destroy に変更（ユーザー削除時に紐づくメッセージも削除）
  has_many :messages, dependent: :destroy

  # ▼（既存）ゲスト関連メソッドはそのまま
  def self.guest_admin
    find_or_create_by!(email: ENV.fetch("GUEST_ADMIN_EMAIL", "guest_admin@example.com")) do |u|
      u.password = SecureRandom.urlsafe_base64(16)
      u.admin    = true
      u.name     = "ゲスト管理者" if u.respond_to?(:name)
    end
  end

  def self.guest_user
    find_or_create_by!(email: ENV.fetch("GUEST_USER_EMAIL", "guest_user@example.com")) do |u|
      u.password = SecureRandom.urlsafe_base64(16)
      u.admin    = false
      u.name     = "ゲストユーザー" if u.respond_to?(:name)
    end
  end
end
