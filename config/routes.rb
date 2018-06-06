Rails.application.routes.draw do
  resources :sessions, only: [:new, :create, :destroy]
 
	get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
	delete '/logout', to: 'sessions#destroy'

  root to: "sessions#homepage"

end
