# README
Despliegue de proyecto de TimboxPayment de forma local:

    * Clanar el proyecto desde git: 

      git clone 
    
    * Cuando se haya descargado realizamos la intalacion dependencias para correr 
      de manera local el proyecto: 

      Para poder correr el proyecto es necesario la instalaccion de ruby 3.1.1 para que pueda corre 

        -Intalacion de ruby 3.1.1 por medio de RENV: 

         rbenv install 3.1.1
        
        -Instalacion de manera global del framework de ruby on rails:

         gem install rails 

         rails --version

        NOTA: este comando se ejecuta desde la ruta root de su pc y dependiendo de la 
              version de ruby que tenga de manera global es la version de rails compatible 
              que se va a instalar, es recomendable especificar la version de rails que se quiere
              ejecutar. El proyecto de TimboxPayment ocupa la rails 7 que es la mas actual por lo 
              cual si se ejecuta el comando de intalacion si especificar la version se instalara 
              la version mas actual.

        -Intalacion de dependencias(gemas) del proyecto: 
         
         +Para el caso de que se ejecuta de manera local es necesario configurar los accesos de 
           aplicaciones no seguras como API, por lo cual es necesario configurar los CORS y evitar 
           errores de que no podemos acceder a los servicios de TimboxPayments desde la parte del 
           Frontend por lo cual es necesario agregar la siguiente gema el Gemfile: 

           gem 'rack-cors', require: 'rack/cors'

           y crear un archivo en la carpeta config->initializers->cors.rb y pegar el siguiente codigo: 

            Rails.application.config.middleware.insert_before 0, Rack::Cors do
                allow do
                    origins 'http://localhost:4200'
                    resource('*',
                            :headers => :any,
                            :methods => [:get, :post, :options, :put, :delete, :patch]
                    )
                end
            end


         rm Gemfile.lock
         
         bundle install 
        
        -Copiar los archivos de configuracion de aplicacion:
          
         application.yml
         secrets.yml
         database.yml
         symmetric-encryption.yml 

         Si en caso de no contar con el archivo de symmetric-encryption.yml se genera mediante el 
         siguiente comando: 

         symmetric-encryption --generate --environments "development"

        

         
