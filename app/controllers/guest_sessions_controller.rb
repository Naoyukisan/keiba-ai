# app/controllers/guest_sessions_controller.rb
class GuestSessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[admin user], raise: false

  # POST /guest_login/admin
  def admin
    admin = User.guest_admin
    sign_out(:user) if user_signed_in?
    sign_in(:user, admin)

    # ★ 変更：RailsAdmin ではなく通常画面へ（必要に応じて gemini_path に）
    redirect_to root_path, notice: "ゲスト管理者としてログインしました。"
    # redirect_to gemini_path, notice: "ゲスト管理者としてログインしました。"
  end

  # POST /guest_login/user
  def user
    guest = User.guest_user
    sign_out(:user) if user_signed_in?
    sign_in(:user, guest)
    redirect_to gemini_path, notice: "ゲストユーザーとしてログインしました。"
  end
end
