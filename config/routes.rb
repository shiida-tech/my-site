Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "home#index"

  resources :blog_posts, only: [ :index, :show ], path: "blog"

  namespace :admin do
    root "dashboard#index"
    resources :categories, except: [ :show ]
    resources :blog_posts do
      member do
        post :publish
        post :unpublish
        get  :preview
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
