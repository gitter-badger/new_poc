
Rails.application.routes.draw do
  resources :blog, only: [:index]
  resources :posts, only: [:new, :create, :show, :edit]
  resources :users, except: [:destroy]
  resources :sessions, only: [:new, :create, :destroy]

  root to: 'blog#index'
end
