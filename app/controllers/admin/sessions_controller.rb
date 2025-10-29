# frozen_string_literal: true

class Admin::SessionsController < Devise::SessionsController
  layout "auth"  # 無ければ削除OK
  respond_to :html, :turbo_stream

  # GET /admin/sign_in
  def new
    super
  end

  # POST /admin/sign_in
  def create
    # 例外を投げない authenticate を使用（500回避）
    self.resource = warden.authenticate(auth_options) # Deviseの流儀

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

    # 管理者OK
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)

    # ← ここは after_sign_in_path_for に任せる（下で上書き）
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # DELETE /admin/sign_out
  def destroy
    super
  end

  private

  # ログイン成功後は保存済み遷移先があればそこへ、なければ認証済みトップへ
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || authenticated_root_path
  end

  # サインアウト後は管理者ログインへ
  def after_sign_out_path_for(_resource_or_scope)
    new_admin_session_path
  end
end
