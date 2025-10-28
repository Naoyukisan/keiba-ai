class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @users = User.all.order(:id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path, notice: "ユーザーを追加しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "ユーザー情報を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if current_user.id == @user.id
      redirect_to admin_users_path, alert: "自分自身は削除できません。"
    else
      @user.destroy
      redirect_to admin_users_path, notice: "ユーザーを削除しました。"
    end
  end

  private

  def require_admin
    redirect_to (user_signed_in? ? authenticated_root_path : unauthenticated_root_path),
            alert: "権限がありません。" unless current_user&.admin?
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin)
  end
end
