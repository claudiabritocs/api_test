require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      get "posts/index"
      resources :users, only: [ :index, :create ]
      resources :posts, only: [ :index, :create ]
      resources :ratings, only: [ :index, :create ]
    end
  end
end
