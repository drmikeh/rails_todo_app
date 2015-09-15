Rails.application.routes.draw do

  resources :sessions, only:[:new, :create, :destroy]

  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'

  resources :users
  resources :todos
  match 'todos/:id/toggle_completed', to: 'todos#toggle_completed', via: 'get'

  root to: 'static_pages#home'
  match '/about', to: 'static_pages#about', via: 'get'

end
