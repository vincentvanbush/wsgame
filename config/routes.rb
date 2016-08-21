Rails.application.routes.draw do
  get 'games/create'

  get 'games/show'

  mount ActionCable.server => '/cable'
  root to: 'pages#main'
  resources :rooms, param: :name do
    resources :games
  end
  resources :messages
  resources :users do
    collection do
      post 'login'
    end
  end
  resources :games
end
