class MassiveDownloadDescargaWorker

  include I18n::Base
  require 'process_soap.rb'

  def perform
    begin
      request_massive_download = MassiveRequest.where("status = 3").limit(15)
      request_massive_download.each do |request_massive|
        request_id = request_massive.request_id_sat
        massive_download_packages = MassiveDownloadPackage.new.select_package_process(request_id)
        if massive_download_packages.present?
          process_soap = ProcessSoap::ProcesoDescargaMasiva.new
          massive_download_packages.each do |package|
            # hay que realizar el auntentificado
            begin
              token = process_soap.get_token(package.fiel64, package.key64)
            rescue Exception => e
              Rails.logger.debug("Se ha producido error generando token de autenticacion. Error: #{e.message}")
              raise SecurityError, "Se ha producido error generando token de autenticacion. Error: #{e.message}"
            end
            # ahora a que realizar la peticion para  descargar el paquete
            begin
              package_id = package.paquete_id
              rfc = package.receive_rfc
              cer = package.fiel64
              key = package.key64
              request_id = package.massive_download_id
              envelope = process_soap.get_firma_descarga(package_id, rfc, cer, key)
              uri = URI.parse(ENV['sat_descarga_masivo_wsdl'])
              https = Net::HTTP.new(uri.host, uri.port)
              https.use_ssl = true
              https.verify_mode = OpenSSL::SSL::VERIFY_NONE
              https.read_timeout = 70
              https.open_timeout = 70
              request = Net::HTTP::Post.new(uri.path)
              request['Authorization'] = 'WRAP access_token="' + token + '"'
              request['Content-Type'] = 'text/xml; charset=UTF-8'
              request['SOAPAction'] = "http://DescargaMasivaTerceros.sat.gob.mx/IDescargaMasivaTercerosService/Descargar"
              request.body = envelope
              request.body.force_encoding('UTF-8')
              response = https.request(request)
              if response.code == "200"
                xml = Nokogiri::XML::Document.parse(response.body)
                codido_estatus = xml.xpath("//h:respuesta/@CodEstatus", "xmlns:h" => "http://DescargaMasivaTerceros.sat.gob.mx").text
                mensaje = xml.xpath("//h:respuesta/@Mensaje", "xmlns:h" => "http://DescargaMasivaTerceros.sat.gob.mx").text
                if codido_estatus == "5000" && (mensaje.include? "Solicitud Aceptada")
                  xml.remove_namespaces!
                  result_package = xml.xpath("//RespuestaDescargaMasivaTercerosSalida/Paquete").text
                  if result_package != ""
                    #una vez que se obtenga el archivo en base64 hay que guardalo
                    path = "#{Rails.root}/vendor/descarga_masiva/paquetes/#{package.massive_download_id}/"
                    FileUtils.mkdir_p path unless Dir.exist?(path)
                    File.open("#{path}/#{package_id}.zip", "wb") do |f|
                      f.write(Base64.decode64(result_package))
                    end
                    package.estatus = 1
                    package.descargado = 1
                    package.save!
                  end
                  Rails.logger.debug("Paquete Descargado correctamente.")
                else
                  take_status(codido_estatus, package_id)
                  massive_download_log = MassiveDownloadLog.new
                  massive_download_log.solicitud_id = request_massive.id
                  massive_download_log.worker = 'DescargaPaquetes'
                  massive_download_log.error_code = codido_estatus
                  massive_download_log.message = mensaje
                  massive_download_log.emmiter_id = package.emmiter_id
                  massive_download_log.save!
                  Rails.logger.debug("Error de descarga: Codigo: #{codido_estatus}, Mensaje: #{mensaje}.")
                end
              else
                Rails.logger.debug("Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}.")
                raise "Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}."
              end
            rescue Exception => e
              Rails.logger.debug("#{e.message}")
              raise "#{e.message}"
            end
          end
          all_downlaoaded_packages = MassiveDownloadPackage.new.is_change_estatus_request(request_id)
          if all_downlaoaded_packages
            request_massive.status = '7'
            request_massive.save!
          end

        else
          Rails.logger.debug("No encontrados solicitudes aceptadas")
          return false
        end
      end
    rescue => e
      ExceptionNotifier.notify_exception(e, :data => { :message => "Error en el MassiveDownloadDescargaWorker: #{e.backtrace}" })
      raise e
    end
  end

  def take_status(package_id, code)
    package = MassiveDownloadPackage.find_by(massive_download_id: package_id)
    if code == '5004' || code == '5007' || code == '5008'
      package.estatus = 3
      package.save!
    end
  end

end