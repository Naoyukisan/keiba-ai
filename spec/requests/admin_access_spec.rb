# spec/requests/admin_access_spec.rb
require "rails_helper"

RSpec.describe "Admin access guard", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user)  { create(:user) }

  it "未ログインはサインインへリダイレクト" do
    get "/admin/users"
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(new_user_session_path)
  end

  it "一般ユーザーは拒否（トップ等へリダイレクト）" do
    sign_in user
    get "/admin/users"
    expect(response).to have_http_status(:found)
    # ここは実装に合わせて（例：root_path や new_admin_session_path など）
    expect(response).to redirect_to(root_path).or redirect_to(new_admin_session_path)
  end

  it "管理者はアクセスできる" do
    sign_in admin
    get "/admin/users"
    expect(response).to have_http_status(:ok)
  end
end
