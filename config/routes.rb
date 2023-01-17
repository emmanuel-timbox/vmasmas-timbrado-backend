Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :emitter_configs
  resources :receiver_configs
  resources :concept_configs
  resources :tax_configs
  resources :create_xml do
    get "receivers_show", on: :member
  end

end
