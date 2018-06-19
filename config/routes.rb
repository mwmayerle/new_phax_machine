Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:index, :show]
  resources :user_emails
	resources :clients
  resources :fax_numbers, only: [:index, :edit, :update]
  root to: "users#index" #change this in the future

end
