Rails.application.routes.draw do
  mount Dune::Balanced::Creditcard::Engine => '/', as: :dune_balanced_creditcard

  resources :projects do
    resources :contributions
    resources :matches
  end
end
