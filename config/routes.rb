Rails.application.routes.draw do
  post '/login', to: 'tokens#create'
  delete '/login', to: 'tokens#destroy'
  resources :users
  resources :articles
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
