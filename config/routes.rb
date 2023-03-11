Rails.application.routes.draw do
  resources :links
  resources :contacts
  resources :shipments
  resources :shippings
  devise_for :users

  root to: "static#dashboard"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
