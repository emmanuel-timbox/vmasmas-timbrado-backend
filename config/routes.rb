Rails.application.routes.draw do

  resources :emitter_configs
  resources :receiver_configs
  resources :concept_configs
  resources :tax_configs
  resources :certificate
  resources :employee
  resources :massive
  resources :xml_files
  resources :pdf_image
  resources :authenticate do
    post 'login', on: :member
    get 'logout', on: :member
  end
  resources :massive do
    get 'show_massive', on: :member
    get 'show_packages', on: :member
    post 'send_email', on: :member
  end
  resources :create_xml do
    get 'show_receivers', on: :member
    get 'show_concepts', on: :member
    get 'show_taxes', on: :member
    post 'validate_key', on: :member
  end

end
