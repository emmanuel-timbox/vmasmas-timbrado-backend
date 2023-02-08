Rails.application.routes.draw do

  resources :emitter_configs
  resources :receiver_configs
  resources :concept_configs
  resources :tax_configs
  resources :certificate
  resources :employe
  resources :create_xml do
    get 'show_receivers', on: :member
    get 'show_concepts', on: :member
    get 'show_taxes', on: :member
  end

end
