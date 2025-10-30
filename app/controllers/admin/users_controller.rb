# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: %i[edit update destroy]
  before_action :forbid_guest_change!, only: %i[update destroy]

  def index
    @users = User.order(:id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_create_params)
    if @user.save
      redirect_to admin_users_path, notice: "ユーザーを追加しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    attrs = user_update_params
    attrs.delete(:password) if attrs[:password].blank?
    attrs.delete(:password_confirmation) if attrs[:password_confirmation].blank?
    attrs.delete(:email) if attrs[:email].blank?

    if @user.update(attrs)
      redirect_to admin_users_path, notice: "ユーザー情報を更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。入力内容をご確認ください。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.id == @user.id
      return redirect_to admin_users_path, alert: "自分自身は削除できません。"
    end
    if @user.admin? && User.where(admin: true).where.not(id: @user.id).count.zero?
      return redirect_to admin_users_path, alert: "最後の管理者は削除できません。"
    end

    @user.destroy!
    redirect_to admin_users_path, notice: "ユーザーを削除しました。"

  rescue ActiveRecord::InvalidForeignKey => e
    msg = Rails.env.development? ? "#{e.class}: #{e.message}" : "外部キー制約により削除できません。"
    redirect_to admin_users_path, alert: msg
  rescue ActiveRecord::RecordNotDestroyed => e
    detail = e.record&.errors&.full_messages&.join(", ")
    msg = detail.presence || (Rails.env.development? ? "#{e.class}: #{e.message}" : "削除処理中にエラーが発生しました。")
    redirect_to admin_users_path, alert: msg
  rescue => e
    Rails.logger.error("[Admin::UsersController#destroy] #{e.class}: #{e.message}\n#{e.backtrace.join("\n")}")
    msg = Rails.env.development? ? "#{e.class}: #{e.message}" : "削除処理中にエラーが発生しました。"
    redirect_to admin_users_path, alert: msg
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin
    redirect_to root_path, alert: "権限がありません。" unless current_user&.admin?
  end

  def forbid_guest_change!
    guest_emails = [
      ENV.fetch("GUEST_ADMIN_EMAIL", "guest_admin@example.com"),
      ENV.fetch("GUEST_USER_EMAIL",  "guest_user@example.com")
    ]
    return unless @user.email.in?(guest_emails)
    redirect_to admin_users_path, alert: "ゲストユーザーは編集・削除できません。"
    return
  end

  def user_create_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :admin)
  end

  def user_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :admin)
  end
end
