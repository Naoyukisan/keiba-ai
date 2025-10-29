class Admin::ApplicationController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  private

  def require_admin
    return if current_user&.admin?
    redirect_to new_admin_session_path, alert: "管理者権限が必要です。"
  end
end
