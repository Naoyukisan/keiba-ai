class GuestSessionsController < ApplicationController
  # ← これを追加：未ログインで叩けるようにする
  skip_before_action :authenticate_user!, raise: false
  before_action :redirect_if_signed_in

  def admin
    user = User.guest_admin
    sign_in(:user, user)
    redirect_to new_gemini_path, notice: "ゲスト管理者としてログインしました。"
  end

  def user
    user = User.guest_user
    sign_in(:user, user)
    redirect_to new_gemini_path, notice: "ゲストユーザーとしてログインしました。"
  end

  private

  def redirect_if_signed_in
    redirect_to new_gemini_path if user_signed_in?
  end
end
