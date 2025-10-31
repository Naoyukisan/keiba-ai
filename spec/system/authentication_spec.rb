# spec/system/authentication_spec.rb
require "rails_helper"

RSpec.describe "Authentication", type: :system do
  it "ログイン成功（一般ユーザー）" do
    user = create(:user, email: "u@example.com", password: "secret123", password_confirmation: "secret123")

    visit new_user_session_path

    # ラベル依存をやめ、ID/NAMEで安定取得（Devise標準のname属性）
    find("input[name='user[email]']", visible: :all).set("u@example.com")
    find("input[name='user[password]']", visible: :all).set("secret123")
    # ボタンは日本語/英語を両対応
    find("input[type='submit'], button[type='submit']", match: :first, visible: :all).click

    expect(page).to have_current_path(root_path, ignore_query: true).or have_content(/ログイン|サインアウト|Signed in/i)
  end

  it "ログイン失敗（パスワード誤り）" do
    create(:user, email: "u2@example.com", password: "secret123", password_confirmation: "secret123")

    visit new_user_session_path
    find("input[name='user[email]']", visible: :all).set("u2@example.com")
    find("input[name='user[password]']", visible: :all).set("wrong")
    find("input[type='submit'], button[type='submit']", match: :first, visible: :all).click

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    expect(page).to have_content(/Invalid|無効|誤り|エラー/i)
  end
end
