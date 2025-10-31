# config/routes.rb
Rails.application.routes.draw do
  # Devise（Sessions を users/sessions に差し替え）
  devise_for :users, controllers: { sessions: "users/sessions" }

  # ルートは常に pages#home（未ログイン/ログイン済みを問わず）
  root to: "pages#home"
  get "/home", to: "pages#home" # 直リンク用（任意）

  # RailsAdmin は /ra
  mount RailsAdmin::Engine => "/ra", as: "rails_admin"

  # Gemini
  resource :gemini, only: %i[new create], controller: "gemini"
  get "/gemini", to: "gemini#new"

  # Histories
  resources :histories, only: %i[index show]

  # Prediction Methods（CRUD + 追加アクション）
  resources :prediction_methods do
    post :activate, on: :member
    collection do
      post :activate_previous
      post :revert
    end
  end

  # Improvements
  resources :improvements, only: %i[new create] do
    collection { post :apply }
  end

  # Admin
  namespace :admin do
    resources :users, except: [:show]
  end

  # エラーハンドリング
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # 管理者ログイン画面（Deviseのスコープ）
  devise_scope :user do
    get    "admin/sign_in",  to: "admin/sessions#new",     as: :new_admin_session
    post   "admin/sign_in",  to: "admin/sessions#create",  as: :admin_session
    delete "admin/sign_out", to: "admin/sessions#destroy", as: :destroy_admin_session
  end

  # 管理者トップ（RailsAdmin を使う想定）
  get "admin", to: redirect("/ra"), as: :admin_root

  # ▼ ゲストログイン（Users::SessionsController に集約）
  post "/guest_login/admin", to: "users/sessions#guest_admin", as: :guest_admin_login
  post "/guest_login/user",  to: "users/sessions#guest_user",  as: :guest_user_login
end
