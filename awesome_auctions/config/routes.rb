Rails.application.routes.draw do
  devise_for :users

  resources :products do
    resources :auctions, only: [:create] do
      resources :bids, only: [:create]
    end
  end

  root 'static_pages#home'
end
