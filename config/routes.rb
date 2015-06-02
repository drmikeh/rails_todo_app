Rails.application.routes.draw do
  root to: 'static_pages#home'
  match '/about', to: 'static_pages#about', via: 'get'
end
