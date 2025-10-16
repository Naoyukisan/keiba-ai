Rails.application.routes.draw do
  get "histories/index"
  get "histories/show"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  
  # フォームをトップに
  root "gemini#new"

  resource :gemini, only: %i[new create], controller: "gemini"
  resources :histories, only: [:index, :show]

  # （任意）/gemini に直接アクセスしても new を出すエイリアス
  get "/gemini", to: "gemini#new"

  resources :blogs
  get "up" => "rails/health#show", as: :rails_health_check


end
