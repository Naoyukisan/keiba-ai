# config/routes.rb
Rails.application.routes.draw do
  # Devise
  devise_for :users

  # ログイン済み → 予想トップ
  authenticated :user do
    root to: "gemini#new", as: :authenticated_root
  end

  # 未ログイン → Deviseログイン（※ devise_scope でラップ必須）
  devise_scope :user do
    unauthenticated :user do
      root to: "devise/sessions#new", as: :unauthenticated_root
    end
  end

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
