Rails.application.routes.draw do
  root "forums#index"

  resources :forums, only: %i[index show] do
    resources :threads, only: %i[show new create], controller: "forum_threads" do
      resources :thread_replies, only: %i[create]
    end
  end

  get "members/:id", to: "users#show", as: :member

  get "ai-flags", to: "ai_flags#index", as: :ai_flags

  resources :affiliations, only: %i[index create] do
    member { patch :join }
  end

  resources :fallacy_flags, only: [] do
    member { patch :dismiss }
  end

  namespace :admin do
    get "/", to: "dashboard#index", as: :dashboard
    resource :ai_settings, only: %i[edit update] do
      post :test, on: :collection
    end
    resources :fallacy_definitions, only: %i[index update]
    get "boards", to: "boards#index", as: :boards
    resources :forum_categories, only: %i[create update destroy] do
      collection { patch :reorder }
    end
    resources :forums, only: %i[create update destroy] do
      collection { patch :reorder }
    end
    resources :announcements, only: %i[index create update destroy]
    resource :smtp_settings, only: %i[edit update] do
      post :test, on: :collection
    end
    resources :user_groups, only: %i[index create update destroy]
    resource :storage_settings, only: %i[edit update] do
      post :test, on: :collection
    end
    resources :members, only: %i[index destroy] do
      member do
        patch :toggle_admin
        patch :toggle_lock
      end
    end
    resources :pending_registrations, only: %i[destroy] do
      member { patch :confirm }
    end
  end

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
