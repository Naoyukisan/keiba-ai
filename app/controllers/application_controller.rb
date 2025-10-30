# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  layout :select_layout

  # 既定ではログイン必須。ただし Devise と公開ページは除外
  before_action :authenticate_user!, unless: :public_controller?

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

  # ===== Devise の遷移先をすべて home に統一 =====
  def after_sign_in_path_for(_resource)
    root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  # ===== 未ログインでも通してよいコントローラ/アクション =====
  def public_controller?
    return true if devise_controller? # Devise系は常に許可
    # 公開ページ（PagesController#home など）を許可
    controller_name == "pages" && action_name == "home"
  end

  # よくある「存在しない/見つからない」系は 404 に寄せる
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::RoutingError,   with: :render_not_found

  def render_not_found
    redirect_to "/404"
  end
end
