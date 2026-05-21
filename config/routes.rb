Rails.application.routes.draw do
  resource :session
  # resources :passwords, param: :token
  root "pages#index"

  resources :blog_posts, only: [ :index, :show ], path: "blog"
  resources :inquiries, only: [ :new, :create ]
  get "privacy-policy", to: "pages#privacy_policy"

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
    resources :inquiries, only: [ :index, :show ]
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check
end
