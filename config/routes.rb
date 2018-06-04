Rails.application.routes.draw do
	get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy'

  root to: "users#show"

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
end
