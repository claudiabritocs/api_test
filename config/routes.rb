require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      get "users/by_ip", to: "users#get_by_ip"
      resources :users, only: [ :index, :create ]
      get "posts/best", to: "posts#best_posts"
      resources :posts, only: [ :index, :create ]
      resources :ratings, only: [ :index, :create ]
    end
  end
end
