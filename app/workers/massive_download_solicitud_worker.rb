class MassiveDownloadSolicitudWorker
  include I18n::Base
  require 'process_soap.rb'


  def self.perform(data)

    begin
      process_soap = ProcessSoap::ProcesoDescargaMasiva.new
      begin
        token = process_soap.get_token(data['certificate_pem'], data['key_pem'])
      rescue Exception => e
        Rails.logger.debug("Se ha producido error generando token de autenticacion. Error: #{e.message}")
        raise SecurityError, "Se ha producido error generando token de autenticacion. Error: #{e.message}"
      end
      begin
        envelope = process_soap.get_firma_solicitud(data)
        puts envelope
        uri = URI.parse(ENV['sat_descarga_solicitud_wsdl'])
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.read_timeout = 50
        https.open_timeout = 50
        request = Net::HTTP::Post.new(uri.path)
        request['Authorization'] = 'WRAP access_token="' + token + '"'
        request['Content-Type'] = 'text/xml; charset=UTF-8'
        request['SOAPAction'] = 'http://DescargaMasivaTerceros.sat.gob.mx/ISolicitaDescargaService/SolicitaDescarga'
        request.body = envelope
        request.body.force_encoding('UTF-8')
        response = https.request(request)
        if response.code == "200"
          xml = Nokogiri::XML::Document.parse(response.body)
          xml.remove_namespaces!
          codido_estatus = xml.xpath("//SolicitaDescargaResult/@CodEstatus").text
          mensaje = xml.xpath("//SolicitaDescargaResult/@Mensaje").text
          if codido_estatus == "5000" && (mensaje.include? "Solicitud Aceptada")
            Rails.logger.debug("Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}.")
            massive_download = MassiveRequest.new
            massive_download.request_id_sat = xml.xpath("//SolicitaDescargaResult/@IdSolicitud").text
            massive_download.user_id = data['user_id']
            massive_download.emmiter_id = data['emitter_id']
            massive_download.receive_rfc = data['RfcSolicitante']
            massive_download.emitter_rfc = data['RfcEmisor']
            massive_download.status = 1
            massive_download.start_date = data['FechaInicial']
            massive_download.final_date = data['FechaFinal']
            massive_download.email = data['correo']
            massive_download.slug = EncryptData.encrypt("massive_request_donwload")
            massive_download.save!

            return { is_accepted: true, request_sat_id: xml.xpath("//SolicitaDescargaResult/@IdSolicitud").text}
          else
            return { is_accepted: false}
          end
        else
          Rails.logger.debug("Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}.")
          raise "Error de comunicacion con el servicio(Solicitud)."
        end
      rescue Exception => e
        Rails.logger.debug("#{e.message}")
        raise "#{e.message}"
      end
    rescue => e
      ExceptionNotifier.notify_exception(e, :data => { :message => "Error en el MassiveDownloadSolicitudWorker: #{e.backtrace}" })
      raise e
    end

  end

end