Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :camps, only: %i[index show new create destroy] do
    resources :games, only: %i[new create show edit update destroy]
  end
  resources :players
  resources :teams
  resources :admins, except: :show

  get "/login", to: "sessions#login"
  post "/login", to: "sessions#create"
  get "/login/admin", to: "sessions#login_admin"
  post "/login/admin", to: "sessions#create_admin"
  delete "/logout", to: "sessions#destroy"
  root "home#index"
end
