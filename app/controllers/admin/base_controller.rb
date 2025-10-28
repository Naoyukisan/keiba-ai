class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    return if current_user&.admin?

   redirect_to (user_signed_in? ? authenticated_root_path : unauthenticated_root_path),
            alert: "管理者のみアクセス可能です。"
  end
end