Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  resources :rooms, param: :name
  resources :messages
end
