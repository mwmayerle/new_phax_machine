Rails.application.routes.draw do
	resources :users, only: [:new, :create, :show, :edit, :update, :destroy]
  resources :sessions, only: [:new, :create, :destroy]
  resources :fax_numbers, only: [:index, :edit, :update]
	resources :clients, only: [:index, :new, :create, :edit, :update, :destroy, :show]
	
	get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy'

  root to: "sessions#index" #change this in the future

end
