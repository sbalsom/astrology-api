Rails.application.routes.draw do
  require "sidekiq/web"
  # require 'sidekiq/cron/web'
  authenticate :user, lambda { |u| u.admin } do
    mount Sidekiq::Web => '/sidekiq'
  end
  devise_for :users
  root to: 'pages#home'
  namespace :api do
    namespace :v1 do
      resources :horoscopes, only: [ :index, :show ]
      resources :publications, only: [ :index, :show ]
      resources :authors, only: [:index, :show]
    end
  end
end
