Rails.application.routes.draw do
  devise_for :users
  resources :products do
    resources :auctions, only: [:create]
  end
  root 'static_pages#home'
end
