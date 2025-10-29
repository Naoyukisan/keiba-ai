# app/controllers/admin/sessions_controller.rb
# frozen_string_literal: true

class Admin::SessionsController < Devise::SessionsController
  layout "auth"  # そのレイアウトが無ければこの行は消してOK
  respond_to :html, :turbo_stream

  # GET /admin/sign_in
  def new
    super
  end

  # POST /admin/sign_in
  def create
    # 例外を投げない authenticate を使って自前分岐（500回避）
    self.resource = warden.authenticate(scope: :user)

    if resource.nil?
      # 認証失敗（メール or パス）
      flash.now[:alert] = I18n.t("devise.failure.invalid", authentication_keys: "メールアドレス")
      return render :new, status: :unprocessable_entity
    end

    unless resource.admin?
      # 一般ユーザーは拒否
      sign_out(:user)
      return redirect_to new_admin_session_path, alert: "管理者権限がありません。"
    end

    # 管理者OK
    set_flash_message!(:notice, :signed_in)
    sign_in(:user, resource)
    redirect_to admin_root_path
  end

  # DELETE /admin/sign_out
  def destroy
    sign_out(:user)
    redirect_to new_admin_session_path, notice: I18n.t("devise.sessions.signed_out")
  end
end
