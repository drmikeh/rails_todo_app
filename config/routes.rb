Rails.application.routes.draw do
  resources :users
  resources :todos

  resources :sessions, only:[:new, :create, :destroy]

  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  root to: 'static_pages#home'
  match '/about', to: 'static_pages#about', via: 'get'
end
