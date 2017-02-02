Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  get 'welcome/index'
  root to: "welcome#index"
  get '/users', to: 'users#index', as: 'users'
  get '/users/:login', to: 'users#show', as: 'userprofil'
  get '/movies', to: 'movies#index', as: 'movies'

end
