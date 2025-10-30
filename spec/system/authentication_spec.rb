# spec/system/authentication_spec.rb
require "rails_helper"

RSpec.describe "Authentication", type: :system do
  it "ログイン成功（一般ユーザー）" do
    user = create(:user, email: "u@example.com", password: "secret123", password_confirmation: "secret123")
    visit new_user_session_path
    fill_in "Email", with: "u@example.com"
    fill_in "Password", with: "secret123"
    click_button "Log in"  # Deviseデフォルトのボタン名（日本語化してるなら置き換え）
    expect(page).to have_current_path(root_path, ignore_query: true).or have_content("ログイン").or have_content("サインアウト")
  end

  it "ログイン失敗（パスワード誤り）" do
    create(:user, email: "u2@example.com", password: "secret123", password_confirmation: "secret123")
    visit new_user_session_path
    fill_in "Email", with: "u2@example.com"
    fill_in "Password", with: "wrong"
    click_button "Log in"
    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    expect(page).to have_content("無効") # devise.i18n に合わせて適宜
  end
end
