Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  # post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  resources :users do
    
    member do
      #/users/:id/...
      #follwing_user GET    /users/:id/follwing(.:format)   users#follwing
      #followers_user GET    /users/:id/followers(.:format) users#followers
      get :following,:followers
      #GET /users/1/following => following action
      #GET /users/1/followers => followers action
    end
  end
  resources :account_activations,only:[:edit]
  #edit_account_activation_url(activation_token)
   #params[:id] <== activation_token(有効化トークン)
   # => GET "/account_activations/params[:id]/edit"
   #Controller: params[:id]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
end
