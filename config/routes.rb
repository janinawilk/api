Rails.application.routes.draw do

  post '/login', to: 'tokens#create'
  delete '/login', to: 'tokens#destroy'
  resources :users
  resources :articles do
    resources :comments, only: [:index, :create]
  end
end
