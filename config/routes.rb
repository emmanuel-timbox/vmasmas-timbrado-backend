Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :tax_data_configs
  resources :receiver_configs


  # get 'prueba-ruta', to: 'pruebas(controlado)#prueba(metodo)'

end
