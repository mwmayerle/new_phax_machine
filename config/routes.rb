Rails.application.routes.draw do
	resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :fax_numbers, only: [:index, :edit, :update]
	resources :clients, only: [:index, :new, :create, :edit, :destroy]
	
	get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy'

  root to: "sessions#index" #change this in the future

end
