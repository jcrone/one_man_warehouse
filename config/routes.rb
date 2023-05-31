Rails.application.routes.draw do
  
  resources :locations do 
    resources :boxes do 
      resources :inventories
    end 
  end
  resources :orders
  resources :inventories, only: [:index, :destroy, :show]
  resources :messages
  resources :expenses
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  resources :hours
  resources :todos
  resources :employees
  resources :links
  resources :contacts
  resources :shipments
  resources :shippings
  devise_for :users
  get 'sync', to: 'inventories#sync'

  delete 'delete_shipment_file', to: 'shipments#delete_shipment_file'
  root to: "static#dashboard"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
