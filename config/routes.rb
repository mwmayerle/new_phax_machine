Rails.application.routes.draw do
  resources :fax_numbers
	resources :users
  resources :sessions, only: [:new, :create, :destroy]
 	
  get '/admin', to: 'users#admin_console'

	get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy'

  root to: "sessions#index" #change this in the future

end
