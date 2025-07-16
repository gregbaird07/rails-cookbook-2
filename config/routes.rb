Rails.application.routes.draw do
  devise_for :users
  
  # Root route
  root "home#index"
  
  # Home routes
  get "home/index"
  
  # Recipe routes
  resources :recipes do
    collection do
      post :parse_url
    end
    
    # Nested reviews routes
    resources :reviews, only: [:create, :destroy]
    
    # Favorites toggle
    post 'favorite', to: 'favorites#toggle'
  end
  
  # Collections routes
  resources :collections do
    member do
      post 'add_recipe/:recipe_id', to: 'collections#add_recipe', as: 'add_recipe_to'
      delete 'remove_recipe/:recipe_id', to: 'collections#remove_recipe', as: 'remove_recipe_from'
    end
  end
  
  # User profile routes with nested collections
  resources :users, only: [:show] do
    resources :collections, only: [:index]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
