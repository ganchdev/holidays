# frozen_string_literal: true

Rails.application.routes.draw do
  root "dashboard#index"
  scope controller: :auth do
    get "/auth", action: :new
    get "/auth/:provider/callback", action: :callback
    match :logout, action: :destroy, via: [:delete, :get]
  end

  namespace :admin do
    get "/", to: "accounts#index"
    resources :accounts
    resources :users
    resources :authorized_users
    resources :authorized_users
  end

  resources :accounts, only: [:new, :create]
  resources :properties do
    resources :rooms do
      resources :reservations
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
