Rails.application.routes.draw do
  root "home#index"

  resources :barangays
  resources :cities
  resources :provinces
  resources :regions
  resources :countries
end
