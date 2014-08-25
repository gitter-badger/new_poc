
Rails.application.routes.draw do
  resources :blog, only: [:index]
  resources :posts, except: [:destroy]
  resources :users, except: [:destroy]
  resources :sessions, only: [:new, :create, :destroy]

  root to: 'blog#index'
end
