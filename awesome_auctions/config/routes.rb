Rails.application.routes.draw do
  resources :products
  root 'static_pages#home'
end
