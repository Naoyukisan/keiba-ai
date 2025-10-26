# config/routes.rb
Rails.application.routes.draw do
  # Devise
  devise_for :users

  # ルート：未ログイン→ログイン画面 / ログイン済→予想トップ
  unauthenticated :user do
    root to: "devise/sessions#new"
  end
  authenticated :user do
    root to: "gemini#new", as: :authenticated_root
  end

  # RailsAdmin は /ra に退避（/admin との衝突回避）
  mount RailsAdmin::Engine => "/ra", as: "rails_admin"

  # Gemini
  resource :gemini, only: %i[new create], controller: "gemini"
  get "/gemini", to: "gemini#new" # 任意

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

  # Improvements（← applyC を apply に修正）
  resources :improvements, only: %i[new create] do
    collection { post :apply }
  end

  # Admin名前空間（/admin/users 等）
  namespace :admin do
    resources :users, only: %i[index new create edit update destroy]
  end
end
