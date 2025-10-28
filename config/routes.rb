# config/routes.rb
Rails.application.routes.draw do
  # Devise（ログイン機能）
  devise_for :users

  # ログイン済み → 予想トップ
  authenticated :user do
    root to: "gemini#new", as: :authenticated_root
  end

  # 未ログイン → トップ（概要ページ）
  unauthenticated :user do
    root to: "pages#home", as: :unauthenticated_root
  end
  get "/home", to: "pages#home"  # 直リンク用（任意）

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
end
