Rails.application.routes.draw do
	resources :users
  resources :emails
	resources :clients
  resources :sessions, only: [:new, :create, :destroy]
  resources :fax_numbers, only: [:index, :edit, :update]
	
	get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy'

  root to: "sessions#index" #change this in the future

end
