Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  resources :chatrooms, param: :topic
  resources :messages
end
