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

	resources :faxes, only: [:new, :create]
	resources :user_fax_numbers, only: [:edit, :update]
	resources :mailgun_faxes, only: [:fax_received, :fax_sent, :mailgun]
  resources :users, only: [:index, :edit, :update, :org_index]
	resources :organizations
  resources :fax_numbers, only: [:index, :edit, :update, :new, :create]
  resources :fax_logs, only: [:index, :create, :download]
  resources :readmes, only: [:show]

  root to: "faxes#new"

  get "/org-users", to: "users#org_index"

  post "/fax_received", to: "mailgun_faxes#fax_received"
  post "/fax_sent", to: "mailgun_faxes#fax_sent"
  post "/mailgun", to: "mailgun_faxes#mailgun"

  get "/download/:fax_id", to: "fax_logs#download"

  get "/readme", to: "readmes#show"
end