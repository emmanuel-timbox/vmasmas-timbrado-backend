class MassiveDownloadVerifyWorker

  include I18n::Base
  require 'process_soap.rb'

  def perform
    begin
      massive_download = MassiveRequest.select_solicitud_fiel
      if massive_download.present?

        process_soap = ProcessSoap::ProcesoDescargaMasiva.new
        massive_download.each do |solicitud|

          begin
            token = process_soap.get_token(solicitud.fiel64, solicitud.key64)
          rescue Exception => e
            Rails.logger.debug("Se ha producido error generando token de autenticacion. Error: #{e.message}")
            raise SecurityError, "Se ha producido error generando token de autenticacion. Error: #{e.message}"
          end

          begin
            solicitud_id = solicitud.request_id_sat
            rfc = solicitud.receive_rfc
            fiel = solicitud.fiel64
            key = solicitud.key64
            envelope = process_soap.get_firma_verificar(solicitud_id, rfc, fiel, key)


            uri = URI.parse(ENV['sat_descarga_verificar_wsdl'])
            https = Net::HTTP.new(uri.host, uri.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE
            https.read_timeout = 40
            https.open_timeout = 40
            request = Net::HTTP::Post.new(uri.path)
            request['Authorization'] = 'WRAP access_token="' + token + '"'
            request['Content-Type'] = 'text/xml; charset=UTF-8'
            request['SOAPAction'] = "http://DescargaMasivaTerceros.sat.gob.mx/IVerificaSolicitudDescargaService/VerificaSolicitudDescarga"
            request.body = envelope
            request.body.force_encoding('UTF-8')
            response = https.request(request)

            Rails.logger.debug(response)

            if response.code == "200"
              xml = Nokogiri::XML::Document.parse(response.body)
              xml.remove_namespaces!
              codigo_estatus = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@CodEstatus").text
              mensaje = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@Mensaje").text

              if codigo_estatus == "5000" && (mensaje.include? "Solicitud Aceptada")
                codigo_estatus_solicitud = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@EstadoSolicitud").text
                codigo_estado_solicitud = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@CodigoEstadoSolicitud").text

                if codigo_estado_solicitud == "5000" || codigo_estado_solicitud =="5010"
                  solicitud.status = codigo_estatus_solicitud

                  if codigo_estatus_solicitud == '3'
                    packages = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/IdsPaquetes")

                    if packages.count > 0
                      solicitud.cantidad_paquetes = packages.count

                      packages.each do |paquete|
                        if MassiveDownloadPackage.find_by(id: solicitud_id, massive_download_id: paquete.content).nil?
                          packages_download = MassiveDownloadPackage.new
                          packages_download.massive_download_id = solicitud_id
                          packages_download.paquete_id = paquete.content
                          packages_download.estatus = 0
                          packages_download.descargado = 0
                          packages_download.emmiter_id = solicitud.emmiter_id
                          packages_download.save!
                        end

                        Rails.logger.debug("#{response.body}")
                        Rails.logger.debug("paquetes")

                      end

                    else
                      solicitud.cantidad_paquetes = 0
                      Rails.logger.debug("#{response.body}")
                      Rails.logger.debug("No paquetes encontrados. idadhahwdiahwdh")
                      raise "No paquetes encontrados."
                    end

                    Rails.logger.debug("#{response.body}")
                  else
                    solicitud.save!
                    Rails.logger.debug(response.body)
                  end

                  solicitud.save!
                  Rails.logger.debug(response.body)

                else
                  take_mistake_code_state_request(codigo_estado_solicitud, mensaje, solicitud_id)
                  Rails.logger.debug("#{response.body}")
                  Rails.logger.debug("Error de verificacion: #{mensaje}.")
                  raise "Error de verificacion:  Codigo: #{codigo_estado_solicitud}, Mensaje: #{mensaje}."
                end

              else
                take_mistake_code_status(codigo_estatus, mensaje, solicitud_id)
                Rails.logger.debug("#{response.body}")
                Rails.logger.debug("Error de verificacion: #{mensaje}.")
                raise "Error de verificacion:  Codigo: #{codigo_estatus}, Mensaje: #{mensaje}."
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

      else
        Rails.logger.debug("No encontrados solicitudes aceptadas")
        return false
      end

    rescue => e
      # en esta parte hay que hacer  el guardado de los errores en la base de datos
      #ExceptionNotifier.notify_exception(e, :data => { :message => "Error en el MassiveDownloadVerificarWorker: #{e.backtrace}" })
      raise e
    end
  end

  def take_mistake_code_status(status_code, message, request_id)
    massive_download = MassiveRequest.find_by(request_id_sat: request_id)
    massive_download_log = MassiveDownloadLog.new
    massive_download_log.solicitud_id = request_id
    massive_download_log.worker = 'Validar'
    massive_download_log.error_code = status_code
    massive_download_log.message = message
    massive_download_log.emmiter_id = massive_download.emmiter_id

    if status_code == '304'
      massive_download.status = '4'
      massive_download.save!
    end
    if status_code == '5004'
      massive_download.status = '0'
      massive_download.save!
    end
    massive_download_log.save!
  end

  def take_mistake_code_state_request(status_state_code, message, request_id)
    massive_download = MassiveRequest.find_by(request_id_sat: request_id)
    massive_download_log = MassiveDownloadLog.new
    massive_download_log.solicitud_id = request_id
    massive_download_log.worker = 'Validar'
    massive_download_log.error_code = status_state_code
    massive_download_log.message = message
    massive_download_log.emmiter_id = massive_download.emmiter_id

    if status_state_code == '5003'
      massive_download.status = '5-3'
      massive_download.save!
    end

    if status_state_code == '5004'
      massive_download.status = '0-4'
      massive_download.save!
    end

    if status_state_code == '5005'
      massive_download.status = '5'
      massive_download.save!
    end

    massive_download_log.save!
  end













end