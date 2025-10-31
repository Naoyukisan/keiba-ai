# app/controllers/users/sessions_controller.rb
module Users
  class SessionsController < Devise::SessionsController
    def guest_admin
      user = User.guest_admin
      sign_in(user)
      redirect_to root_path, notice: "ゲスト管理者としてログインしました。"
    end

    def guest_user
      user = User.guest_user
      sign_in(user)
      redirect_to root_path, notice: "ゲストユーザーとしてログインしました。"
    end
  end
end
