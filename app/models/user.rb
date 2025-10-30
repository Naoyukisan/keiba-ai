# app/models/user.rb
class User < ApplicationRecord
  # Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :prediction_histories, dependent: :nullify

  # ▼ ここから追記
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
  # ▲ 追記ここまで
end
