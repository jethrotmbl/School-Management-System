Rails.application.routes.draw do
  get 'testit/index'
  root "home#index"

  resources :students do
    collection { get :search }
  end
  resources :teachers do
    collection { get :search }
  end
  resources :guardians do
    collection { get :search }
  end
  resources :departments
  resources :school_years do
    member { patch :open }
  end
  resources :degrees
  resources :field_of_studies
  resources :academic_classes
  resources :enrollment_periods do
    member { patch :set_current }
  end
  resources :enrollments
  resources :citizenships
  resources :barangays
  resources :cities
  resources :provinces
  resources :regions
  resources :countries
end
