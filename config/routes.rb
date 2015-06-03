Rails.application.routes.draw do
  resources :sessions, only:[:new, :create, :destroy]
  resources :users
  resources :todos
  root to: 'static_pages#home'
  match '/about', to: 'static_pages#about', via: 'get'

  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

end
