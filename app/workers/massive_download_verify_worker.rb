class MassiveDownloadVerifyWorker

  include I18n::Base
  require 'process_soap.rb'

  def perform
    begin
      massive_download = MassiveRequest.select_solicitud_fiel
      process_soap = ProcessSoap::ProcesoDescargaMasiva.new

      unless massive_download.present?
        Rails.logger.debug("No encontrados solicitudes aceptadas")
        return false
      end

      massive_download.each do |solicitud|
        begin
          token = process_soap.get_token(solicitud.fiel64, solicitud.key64)
        rescue Exception => e
          Rails.logger.debug("Se ha producido error generando token de autenticacion. Error: #{e.message}")
          raise SecurityError, "Se ha producido error generando token de autenticacion. Error: #{e.message}"
        end

        begin
          rfc = solicitud.receive_rfc
          fiel = solicitud.fiel64
          key = solicitud.key64
          solicitud_id = solicitud.request_id_sat
          uri = ENV['sat_descarga_verificar_wsdl']
          envelope = process_soap.get_firma_verificar(solicitud_id, rfc, fiel, key)
          soap_action = "http://DescargaMasivaTerceros.sat.gob.mx/IVerificaSolicitudDescargaService/VerificaSolicitudDescarga"
          response = process_soap.http_massive_request(uri, soap_action, token, envelope)

          Rails.logger.debug(response)

          if response.code != "200"
            Rails.logger.debug("Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}.")
            raise "Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}."
          end

          xml = Nokogiri::XML::Document.parse(response.body)
          xml.remove_namespaces!
          codigo_estatus = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@CodEstatus").text
          mensaje = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@Mensaje").text
          codigo_estatus_solicitud = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@EstadoSolicitud").text
          codigo_estado_solicitud = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/@CodigoEstadoSolicitud").text

          puts xml
          # esta es una validacion para revisar si la peticion a sido aceptada
          if codigo_estatus != "5000" && (!mensaje.include? "Solicitud Aceptada")
            take_mistake_code_status(codigo_estatus, mensaje, solicitud_id)
            Rails.logger.debug("Error de verificacion: #{mensaje}.")
            raise "Error de verificacion:  Codigo: #{codigo_estatus}, Mensaje: #{mensaje}."
          end

          # si la solicitud ha sido acceptada, revisamos el estatus en que se encuentra,
          if !['5000', '5010'].include?(codigo_estado_solicitud)
            take_mistake_code_state_request(codigo_estado_solicitud, mensaje, solicitud_id)
            Rails.logger.debug("Error de verificacion: #{mensaje}.")
            raise "Error de verificacion:  Codigo: #{codigo_estado_solicitud}, Mensaje: #{mensaje}."
          end

          solicitud.status = codigo_estatus_solicitud
          if codigo_estatus_solicitud != '3'
            solicitud.save!
            Rails.logger.debug("Para la solicitud con el ID: #{solicitud_id} no se encontraron paquetes para descargar")
            next
          end

          packages = xml.xpath("//VerificaSolicitudDescargaResponse/VerificaSolicitudDescargaResult/IdsPaquetes")
          if packages.count == 0
            solicitud.cantidad_paquetes = 0
            solicitud.save!
            Rails.logger.debug("Para la solicitud con el ID: #{solicitud_id} no se encontraron paquetes para descargar")
            next
          end

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
          end
          solicitud.save!
          Rails.logger.debug("Se encontraron paquetes para sus descarga en la solicitud con el ID: #{solicitud_id}")

        rescue Exception => e
          Rails.logger.debug("#{e.message}")
          next
        end

      end

    rescue => e
      # en esta parte hay que hacer  el guardado de los errores en la base de datos
      # ExceptionNotifier.notify_exception(e, :data => { :message => "Error en el MassiveDownloadVerificarWorker: #{e.backtrace}" })
      raise e
    end
  end

  private

  def take_mistake_code_status(status_code, message, request_id)
    massive_request = MassiveRequest.update_code_status(request_id, status_code)
    MassiveDownloadLog.insert_massive_log(massive_request, status_code, message, 'Validar')
  end

  def take_mistake_code_state_request(status_state_code, message, request_id)
    massive_request_data = MassiveRequest.update_state_massive_request(request_id, status_state_code)
    MassiveDownloadLog.insert_massive_log(massive_request_data, status_state_code, message, 'Validar')
  end

end