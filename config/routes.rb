Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root to: 'pages#main'
  resources :rooms, param: :name
  resources :messages
  resources :users do
    collection do
      post 'login'
    end
  end
end
