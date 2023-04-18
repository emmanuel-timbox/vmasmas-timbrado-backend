module ProcessSoap

  require 'openssl'

  class ProcesoDescargaMasiva

    def http_massive_request(uri ,soap_action, token, envelope)
      uri = URI.parse(uri)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      https.read_timeout = 50
      https.open_timeout = 50

      request = Net::HTTP::Post.new(uri.path)
      request['Authorization'] = 'WRAP access_token="' + token + '"'
      request['Content-Type'] = 'text/xml; charset=UTF-8'
      request['SOAPAction'] = soap_action
      request.body = envelope
      request.body.force_encoding('UTF-8')

      return  https.request(request)
    end

    def get_token(certificate, key)
      client = Savon.client(
        wsdl: ENV['sat_descarga_autenticacion_wsdl'],
        ssl_verify_mode: :none,
        log: :true,
        log_level: :debug,
        open_timeout: 5, read_timeout: 5)
      envelope = get_xml_signed(certificate, key)
      response = client.call(:autentica, {"xml" => envelope})
      sxml = response.to_s
      xml = Nokogiri::XML(sxml)
      token = xml.xpath("//t:AutenticaResult", "xmlns:t" => "http://DescargaMasivaTerceros.gob.mx")[0].content
    end

    def get_xml_aut
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send("s:Envelope",
                 "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/",
                 "xmlns:u" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"
        ) do
          xml.send("s:Header") do
            xml.send("o:Security",
                     "s:mustUnderstand" => "1",
                     "xmlns:o" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"
            ) do
              xml.send("u:Timestamp", "u:Id" => "_0") do
                time = Time.now.utc
                xml.send("u:Created") do
                  xml.text(time.xmlschema)
                end
                xml.send("u:Expires") do
                  xml.text((time + 5.minutes).xmlschema)
                end
              end
            end
          end
          xml.send("s:Body") do
            xml.send("Autentica", "xmlns" => "http://DescargaMasivaTerceros.gob.mx")
          end
        end
      end
      builder.to_xml
    end

    def get_xml_signed(certificate, key)
      sxml = get_xml_aut
      xml = Nokogiri::XML(sxml)
      #poner el tiempo en el cua me va a durar el token ya que este solo dura un timepo de 5 min
      xml.children[0].children[1].children[1].children[1].children[1].children[0].content = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      # se calculan que del tiempo actual transcurran 5 minutos
      t = Time.now.utc
      t = t + 5 * 60
      xml.children[0].children[1].children[1].children[1].children[3].children[0].content = t.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      signer = Signer.new(xml.to_s)
      #del certicado que se tiene en base de datos en formato
      signer.cert = OpenSSL::X509::Certificate.new(certificate)
      signer.private_key = OpenSSL::PKey::RSA.new(key)
      signer.document.xpath("//wsu:Timestamp", {"wsu" => "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"}).each do |node|
        signer.digest!(node)
      end
      signer.sign!(:security_token => true)
      signer.to_xml
    end

    def get_firma_solicitud(data)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send("s:Envelope", "xmlns" => "http://DescargaMasivaTerceros.sat.gob.mx", "xmlns:des" => "http://DescargaMasivaTerceros.sat.gob.mx", "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:xd" => "http://www.w3.org/2000/09/xmldsig#", ) do
          xml.send("s:Header") do
          end
          xml.send("s:Body") do
            xml.send("des:SolicitaDescarga") do
              xml.send("des:solicitud", ) do
                data.each do |key, value|
                  next if ['user_id', 'emitter_id', 'certificate_pem', 'key_file', 'key_pem', 'cer_file', 'correo', 'password'].include?(key)
                  xml.parent.set_attribute(key, value)
                end
                xml.send('Signature', 'xmlns' => "http://www.w3.org/2000/09/xmldsig#") do
                end
              end
            end
          end
        end
      end

      signer = Signer.new(builder.to_xml, wss: false, canonicalize_algorithm: :c14n_1_0)
      signer.cert = get_certificate_from_pem(data[:certificate_pem])
      private_key, private_key_pem = get_key_from_pem(data[:key_pem])
      signer.private_key = private_key
      signer_node = nil
      signer.document.at_xpath('//des:solicitud').children.each {|node| signer_node = node }
      signer.signature_node = signer_node

      signer.document.xpath("//des:solicitud", {"des" => "http://DescargaMasivaTerceros.sat.gob.mx"}).each do |node|
        signer.digest!(node, :envelope => true, :uri_blank => true, document: node)
      end

      signer.sign!(:issuer_serial => true)
      xml = Nokogiri::XML(signer.to_xml)
      return xml.to_xml
    end

    def get_firma_verificar(request_id_sat, rfc_solicitante, certificate_pem, key_pem)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send("s:Envelope",
                 "xmlns" => "http://DescargaMasivaTerceros.sat.gob.mx",
                 "xmlns:des" => "http://DescargaMasivaTerceros.sat.gob.mx",
                 "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/",
                 "xmlns:xd" => "http://www.w3.org/2000/09/xmldsig#",
                 ) do
          xml.send("s:Header") do
          end
          xml.send("s:Body") do
            xml.send("des:VerificaSolicitudDescarga") do
              xml.send("des:solicitud", "IdSolicitud" => request_id_sat, "RfcSolicitante" => rfc_solicitante) do
                xml.send('Signature', 'xmlns' => "http://www.w3.org/2000/09/xmldsig#") do
                end
              end
            end
          end
        end
      end
      signer = Signer.new(builder.to_xml, wss: false, canonicalize_algorithm: :c14n_1_0)
      signer.cert = get_certificate_from_pem(certificate_pem)
      private_key, private_key_pem = get_key_from_pem(key_pem)
      signer.private_key = private_key
      signer_node = nil
      signer.document.at_xpath('//des:solicitud').children.each {|node| signer_node = node }
      signer.signature_node = signer_node
      signer.document.xpath("//des:solicitud", {"xmlns:des" => "http://DescargaMasivaTerceros.sat.gob.mx"}).each do |node|
        signer.digest!(node, :envelope => true, :uri_blank => true)
      end
      signer.sign!(:issuer_serial => true)
      xml = Nokogiri::XML(signer.to_xml)
      xml.to_xml
    end

    #estos metodos es que usa para descargar los paquetes que retorna la solicitud
    def get_firma_descarga(id_paquete, rfc_solicitante, certificate_pem, key_pem)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send("s:Envelope",
                 "xmlns" => "http://DescargaMasivaTerceros.sat.gob.mx",
                 "xmlns:des" => "http://DescargaMasivaTerceros.sat.gob.mx",
                 "xmlns:s" => "http://schemas.xmlsoap.org/soap/envelope/",
                 "xmlns:xd" => "http://www.w3.org/2000/09/xmldsig#",
                 ) do
          xml.send("s:Header") do
          end
          xml.send("s:Body") do
            xml.send("des:PeticionDescargaMasivaTercerosEntrada") do
              xml.send("des:peticionDescarga", "IdPaquete" => id_paquete, "RfcSolicitante" => rfc_solicitante) do
                xml.send('Signature', 'xmlns' => "http://www.w3.org/2000/09/xmldsig#") do
                end
              end
            end
          end
        end
      end
      signer = Signer.new(builder.to_xml, wss: false, canonicalize_algorithm: :c14n_1_0)
      signer.cert = get_certificate_from_pem(certificate_pem)
      private_key, private_key_pem = get_key_from_pem(key_pem)
      signer.private_key = private_key
      signer_node = nil
      signer.document.at_xpath('//des:peticionDescarga').children.each {|node| signer_node = node }
      signer.signature_node = signer_node
      signer.document.xpath("//des:peticionDescarga", {"xmlns:des" => "http://DescargaMasivaTerceros.sat.gob.mx"}).each do |node|
        signer.digest!(node, :envelope => true, :uri_blank => true)
      end
      signer.sign!(:issuer_serial => true)
      xml = Nokogiri::XML(signer.to_xml)
      xml.to_xml
    end

    def get_certificate_from_pem(certificado_pem)
      begin
        certificado = OpenSSL::X509::Certificate.new(certificado_pem)
      rescue Exception => e
        if e.class == OpenSSL::X509::CertificateError
          certificado_pem = certificado_pem.squish
          certificado_pem = certificado_pem.gsub("-----BEGIN CERTIFICATE-----", "")
          certificado_pem = certificado_pem.gsub("-----END CERTIFICATE-----", "")
          certificado_pem = certificado_pem.gsub("\n", "")
          arr_pem = certificado_pem.chars.each_slice(64).map(&:join)
          cer_pem = "-----BEGIN CERTIFICATE-----\n"
          arr_pem.each do |segment|
            cer_pem = cer_pem + segment + "\n"
          end
          cer_pem = cer_pem + "-----END CERTIFICATE-----"
          certificado = OpenSSL::X509::Certificate.new(cer_pem)
        end
      end
      certificado
    end

    def get_key_from_pem(llave_pem)
      begin
        llave_privada = OpenSSL::PKey::RSA.new(llave_pem)
      rescue Exception => e
        if e.class == OpenSSL::PKey::RSAError
          llave_pem = llave_pem.squish
          if llave_pem.include?("BEGIN RSA PRIVATE KEY")
            rsa = true
            llave_pem = llave_pem.gsub("-----BEGIN RSA PRIVATE KEY-----", "")
            llave_pem = llave_pem.gsub("-----END RSA PRIVATE KEY-----", "")
          else
            rsa = false
            llave_pem = llave_pem.gsub("-----BEGIN PRIVATE KEY-----", "")
            llave_pem = llave_pem.gsub("-----END PRIVATE KEY-----", "")
          end
          llave_pem = llave_pem.gsub("\n", "")
          arr_pem = llave_pem.chars.each_slice(64).map(&:join)
          if rsa
            key_pem = "-----BEGIN RSA PRIVATE KEY-----\n"
          else
            key_pem = "-----BEGIN PRIVATE KEY-----\n"
          end
          arr_pem.each do |segment|
            key_pem = key_pem + segment + "\n"
          end
          if rsa
            key_pem = key_pem + "-----END RSA PRIVATE KEY-----"
          else
            key_pem = key_pem + "-----END PRIVATE KEY-----"
          end
          llave_privada = OpenSSL::PKey::RSA.new(key_pem)
          llave_pem = key_pem
        end
      end
      return llave_privada, llave_pem
    end

  end

end