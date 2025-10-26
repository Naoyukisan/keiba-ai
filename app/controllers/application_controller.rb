# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  layout :select_layout

  # Deviseコントローラ以外はログイン必須
  before_action :authenticate_user!, unless: :devise_controller?

  private

  def select_layout
    devise_auth_layout? ? "auth" : "application"
  end

  def devise_auth_layout?
    return false unless devise_controller?

    auth_actions = {
      "sessions"       => %w[new create],             # ログイン
      "registrations"  => %w[new create],             # サインアップ
      "passwords"      => %w[new create edit update], # パスワード再設定
      "confirmations"  => %w[new create show],        # メール確認
      "unlocks"        => %w[new create],             # アンロック
    }
    actions = auth_actions[controller_name]
    actions&.include?(action_name)
  end

  # ★ログイン後遷移（1つだけ定義）
  def after_sign_in_path_for(resource)
    if resource.respond_to?(:admin?) && resource.admin?
      admin_users_path
    else
      gemini_path  # 一般ユーザーは予想トップへ
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end
end
