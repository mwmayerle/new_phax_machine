Rails.application.routes.draw do

  post '/login', to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy'

  root to: "users#show"

  resources :users
  resources :sessions
end
