Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :horoscopes, only: [ :index, :show ]
      resources :publications, only: [ :index, :show ]
    end
  end
end

