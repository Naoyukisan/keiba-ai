# app/controllers/users/sessions_controller.rb
# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout "auth" rescue nil  # レイアウトが無ければ無視されます
  respond_to :html, :turbo_stream

  # 未ログインでも叩けるように、認証必須のフィルタは置かないこと

  # POST /users/guest_sign_in
  def guest
    user = User.guest_user
    # 既に他アカウントでログインしている場合はいったんサインアウト（仕様は好みで）
    sign_out(:user) if user_signed_in?

    sign_in(:user, user)
    redirect_to gemini_path, notice: "ゲストユーザーとしてログインしました。"
  end
end
