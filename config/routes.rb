Rails.application.routes.draw do
  devise_for :users, controllers: {
  	sessions: 'users/sessions',
  	unlocks: 'users/unlocks',
  	registrations: 'users/registrations',
  	passwords: 'users/passwords',
  	confirmations: 'users/confirmations'
  }
  resources :users, only: [:index, :show, :create]
  resources :user_emails
	resources :clients
  resources :fax_numbers, only: [:index, :edit, :update]
  root to: "users#index" #change this in the future

  post "/users/invite_and_create_client_manager", to: "users#invite_and_create_client_manager"
end

