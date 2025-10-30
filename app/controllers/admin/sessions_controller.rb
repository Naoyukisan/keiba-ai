# app/controllers/admin/sessions_controller.rb
# frozen_string_literal: true

class Admin::SessionsController < Devise::SessionsController
  layout "auth"
  respond_to :html, :turbo_stream

  # GET /admin/sign_in
  def new
    super
  end

  # POST /admin/sign_in
  def create
    # 例外を投げない authenticate を使用（500回避）
    self.resource = warden.authenticate(auth_options)

    if resource.nil?
      # 認証失敗（メール or パスワード）
      flash.now[:alert] = I18n.t("devise.failure.invalid", authentication_keys: "メールアドレス")
      self.resource = resource_class.new(sign_in_params)   # 入力値を保持
      return render :new, status: :unprocessable_entity
    end

    unless resource.admin?
      # 一般ユーザーは拒否（同画面で表示したいので再描画に統一）
      flash.now[:alert] = "管理者権限がありません。"
      sign_out(resource_name)
      self.resource = resource_class.new(sign_in_params)
      return render :new, status: :unprocessable_entity
    end

    # 管理者OK → home へ
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    redirect_to root_path
  end

  # DELETE /admin/sign_out
  def destroy
    # サインアウト後 → home へ
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    redirect_to root_path
  end

  private

  def auth_options
    { scope: :user, recall: "#{controller_path}#new" }
  end
end
