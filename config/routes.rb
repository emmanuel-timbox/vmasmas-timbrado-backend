Rails.application.routes.draw do

  resources :emitter_configs
  resources :receiver_configs
  resources :concept_configs
  resources :tax_configs
  resources :certificate
  resources :create_xml do
    get "receivers_show", on: :member
  end

end
