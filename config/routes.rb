Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :session
  resources :passwords, param: :token
  resources :users, only: [ :new, :create ]
  resource :account, only: [ :edit, :update ]

  namespace :admin do
    root "dashboards#index"
    resources :users, except: [ :new, :create ]
    resources :words do
      member do
        patch :restore
      end
    end
    resources :games, except: [ :edit, :update ] do
      member do
        patch :start
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#landing"
end
