Rails.application.routes.draw do
  devise_for :users, controllers: {
  	sessions: 'users/sessions',
  	unlocks: 'users/unlocks',
  	registrations: 'users/registrations',
  	passwords: 'users/passwords',
  	confirmations: 'users/confirmations',
	  set_new_user_password: "users/passwords#set_new_user_password"
  }
  
  devise_scope :user do
	  get "/users/password/set_new_user_password", to: "users/passwords#set_new_user_password"
	  delete "/users/:id", to: "users/registrations#destroy"
	  delete "/users/sign_out/:id", to: "users/sessions#destroy"
	end

	resources :faxes
	resources :fax_number_user_emails
	resources :mailgun_faxes_controller, only: [:fax_received, :fax_sent, :mailgun]
  resources :users, only: [:index, :show, :create]
  resources :user_emails
	resources :clients
  resources :fax_numbers, only: [:index, :edit, :update]

  root to: "faxes#new"

  post "/fax_received", to: "mailgun_faxes#fax_received"
  post "/fax_sent", to: "mailgun_faxes#fax_sent"
  post "/mailgun", to: "mailgun_faxes#mailgun"
end

