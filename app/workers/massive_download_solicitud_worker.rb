class MassiveDownloadSolicitudWorker
  include I18n::Base
  require 'process_soap.rb'

  def self.perform(data, user_id, emitter_id, email)
    begin
      process_soap = ProcessSoap::ProcesoDescargaMasiva.new
      begin
        token = process_soap.get_token(data[:certificate_pem], data[:key_pem])
      rescue Exception => e
        Rails.logger.debug("Se ha producido error generando token de autenticacion. Error: #{e.message}")
        raise SecurityError, "Se ha producido error generando token de autenticacion. Error: #{e.message}"
      end

      begin
        envelope = process_soap.get_firma_solicitud(data)
        soap_action = 'http://DescargaMasivaTerceros.sat.gob.mx/ISolicitaDescargaService/SolicitaDescarga'
        uri = ENV['sat_descarga_solicitud_wsdl']
        response = process_soap.http_massive_request(uri, soap_action, token, envelope)

        if response.code != "200"
          Rails.logger.debug("Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}.")
          raise "Error de comunicacion con el servicio(Solicitud)."
        end

        xml = Nokogiri::XML::Document.parse(response.body)
        xml.remove_namespaces!
        codido_estatus = xml.xpath("//SolicitaDescargaResult/@CodEstatus").text
        mensaje = xml.xpath("//SolicitaDescargaResult/@Mensaje").text

        if codido_estatus == "5000" && (mensaje.include? "Solicitud Aceptada")
          request_id_sat = xml.xpath("//SolicitaDescargaResult/@IdSolicitud").text
          masssive_request = MassiveRequest.insert_massive_request(data, request_id_sat, user_id, emitter_id, email)

          return masssive_request
        else
          return { is_accepted: false, message: mensaje }
        end

      rescue Exception => e
        Rails.logger.debug("#{e.message}")
        raise "#{e.message}"
      end

    rescue => e
      # ExceptionNotifier.notify_exception(e, :data => { :message => "Error en el MassiveDownloadSolicitudWorker: #{e.backtrace}" })
      raise e
    end
  end

end