Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  scope "(:locale)", locale: /en|fr/ do 	
  	get 'welcome/index'
  	get '/users', to: 'users#index', as: 'users'
  	get '/users/:login', to: 'users#show', as: 'userprofil'
  	get '/movies', to: 'movies#index', as: 'movies'
  	post '/movie/new', to: 'movies#new', as: 'new_movie'
  	get '/movie/:id', to: 'movies#show', as: 'movie'

    post '/comment/new', to: 'comment#new', as: 'new_comment'
    root to: "welcome#index"
  end
end