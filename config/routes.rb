Neighborly::Balanced::Creditcard::Engine.routes.draw do
  resources :payments, only: [:new, :create]

  post 'users/creditcard'
end
