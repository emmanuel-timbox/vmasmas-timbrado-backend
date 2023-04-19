class MassiveDownloadDescargaWorker

  include I18n::Base
  require 'process_soap.rb'

  def perform
    begin
      request_massive_download = MassiveRequest.where("status = 3").limit(15)
      process_soap = ProcessSoap::ProcesoDescargaMasiva.new

      request_massive_download.each do |request_massive|
        request_id = request_massive.request_id_sat
        massive_download_packages = MassiveDownloadPackage.new.select_package_process(request_id)

        unless massive_download_packages.present?
          Rails.logger.debug("No encontrados solicitudes aceptadas")
          return false
        end

        tem_files = TempFile.find_by(request_id_sat: request_massive.request_id_sat)
        rfc = request_massive.receive_rfc
        cer = tem_files.fiel64
        key = tem_files.key64

        # hay que realizar el auntentificado
        begin
          token = process_soap.get_token(cer, key)
        rescue Exception => e
          Rails.logger.debug("Se ha producido error generando token de autenticacion. Error: #{e.message}")
          raise SecurityError, "Se ha producido error generando token de autenticacion. Error: #{e.message}"
        end

        massive_download_packages.each do |package|
          # ahora a que realizar la peticion para  descargar el paquete
          begin
            package_id = package.paquete_id
            request_id = package.massive_download_id
            uri = ENV['sat_descarga_masivo_wsdl']
            envelope = process_soap.get_firma_descarga(package_id, rfc, cer, key)
            soap_action = "http://DescargaMasivaTerceros.sat.gob.mx/IDescargaMasivaTercerosService/Descargar"
            response = process_soap.http_massive_request(uri, soap_action, token, envelope)

            if response.code != "200"
              Rails.logger.debug("Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}.")
              raise "Error de comunicacion con el servicio: Codigo: #{response.code}, Mensaje: #{response.body}."
            end

            xml = Nokogiri::XML::Document.parse(response.body)
            codido_estatus = xml.xpath("//h:respuesta/@CodEstatus", "xmlns:h" => "http://DescargaMasivaTerceros.sat.gob.mx").text
            mensaje = xml.xpath("//h:respuesta/@Mensaje", "xmlns:h" => "http://DescargaMasivaTerceros.sat.gob.mx").text

            if codido_estatus != "5000" && (!mensaje.include? "Solicitud Aceptada")
              take_status(package_id, codido_estatus)
              MassiveDownloadLog.insert_massive_log(request_massive, codido_estatus, mensaje, 'DescargaPaquetes')
              raise "Error de descarga: Codigo: #{codido_estatus}, Mensaje: #{mensaje}."
            end

            xml.remove_namespaces!
            result_package = xml.xpath("//RespuestaDescargaMasivaTercerosSalida/Paquete").text
            if result_package != ""
              # una vez que se obtenga el archivo en base64 hay que guardalo
              path = "#{Rails.root}/vendor/descarga_masiva/paquetes/#{package.massive_download_id}/"
              FileUtils.mkdir_p path unless Dir.exist?(path)
              File.open("#{path}/#{package_id}.zip", "wb") do |f|
                f.write(Base64.decode64(result_package))
              end

              package.estatus = 1
              package.descargado = 1
              package.save!
              Rails.logger.debug("Paquete Descargado correctamente.")
            end

          rescue Exception => e
            Rails.logger.debug("#{e.message}")
            next
          end
        end

        all_downlaoaded_packages = MassiveDownloadPackage.new.is_change_estatus_request(request_id)
        if all_downlaoaded_packages
          request_massive.status = '7'
          request_massive.save!
        end
      end
    rescue Exception => e
      ExceptionNotifier.notify_exception(e, :data => { :message => "Error en el MassiveDownloadDescargaWorker: #{e.backtrace}" })
      raise e
    end
  end

  private

  def take_status(package_id, code)
    package = MassiveDownloadPackage.find_by(paquete_id: package_id)
    if code == '5004' || code == '5007' || code == '5008'
      package.estatus = 3
      package.save!
    end
  end

end