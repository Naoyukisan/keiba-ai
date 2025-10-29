# config/routes.rb
Rails.application.routes.draw do
  # Devise
  devise_for :users

  # ログイン済み → 予想トップ
  authenticated :user do
    root to: "gemini#new", as: :authenticated_root
  end

  # 未ログイン → トップ（概要）
  unauthenticated :user do
    root to: "pages#home", as: :unauthenticated_root
  end
  get "/home", to: "pages#home" # 直リンク用（任意）

  # RailsAdmin は /ra
  mount RailsAdmin::Engine => "/ra", as: "rails_admin"

  # Gemini
  resource :gemini, only: %i[new create], controller: "gemini"
  get "/gemini", to: "gemini#new"

  # Histories
  resources :histories, only: %i[index show]

  # Prediction Methods
  resources :prediction_methods, only: [] do
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
  
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  devise_scope :user do
    get    "admin/sign_in",  to: "admin/sessions#new",     as: :new_admin_session
    post   "admin/sign_in",  to: "admin/sessions#create",  as: :admin_session
    delete "admin/sign_out", to: "admin/sessions#destroy", as: :destroy_admin_session
  end
  
  # 管理者ログイン後の行き先（RailsAdmin を使っているなら /ra に寄せてもOK）
  # 例: RailsAdmin トップへ飛ばす
  get "admin", to: redirect("/ra"), as: :admin_root
end
