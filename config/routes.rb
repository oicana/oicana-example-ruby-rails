Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :templates, only: %i[index show] do
    member do
      post :compile
      post :preview
      post :reset
    end
  end
  resources :certificates, only: :create
  resources :blobs, only: :create
end
