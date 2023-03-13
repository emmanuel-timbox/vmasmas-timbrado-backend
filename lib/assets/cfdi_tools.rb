class CfdiTools

  def self.processed_cfdi(data)
    begin
      xml = Nokogiri::XML(data[:xml]) # esta parte aun no tiene el certificado ni el sello.
      cfdi = add_certificate(xml, data[:slugEmitter])

      origin_string_cfdi = generate_string(cfdi)
      seal_digester = generate_digestion(origin_string_cfdi, data[:keyFile], data[:keyPassword])
      sello = cfdi.xpath('//@Sello')[0]
      sello.content = seal_digester
      request = request_ring(cfdi.to_xml)
      stamped_cfdi = request[:response][:timbrar_cfdi_response][:timbrar_cfdi_result][:xml]

      XmlFile.insert_xml(stamped_cfdi, data[:slugEmitter], data[:note])

      return { data: stamped_cfdi, code: 200, }
    rescue Exception => e
      return { data: nil, error: e.message, code: 500 }
    end
  end

  def self.generate_string(xml)
    begin
      xslt = Nokogiri::XSLT(File.read(ENV['origin_string_file']))
      string_cfdi = xslt.transform(xml)
      return string_cfdi.text.gsub("\n", "")
    rescue
      return nil
    end
  end

  def self.generate_digestion(original_string_cfdi, key_file, key_password)
    begin
      private_key = OpenSSL::PKey::RSA.new(File.read(key_file), key_password)
      digester = OpenSSL::Digest::SHA256.new
      signarture = private_key.sign(digester, original_string_cfdi)
      seal = Base64.strict_encode64(signarture)
      return seal
    rescue
      return nil
    end
  end

  def self.add_certificate(xml, slug)
    data = Certificate.get_certificate(slug)
    certificate_pem = data.certificate_pem
    certificate = certificate_pem.gsub("-----BEGIN CERTIFICATE-----", "")
                                 .gsub("-----END CERTIFICATE-----", "").gsub("\n", "")
    set_certificate = xml.xpath('//@Certificado')[0]
    date_cfdi = xml.xpath('//@Fecha')[0]
    set_certificate.content = certificate
    date_cfdi.content = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
    return xml
  end

  def self.request_ring(xml)
    encode_xml = Base64.strict_encode64(xml)
    envelope = %Q^
      <soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:urn=\"urn:WashOut\">
        <soapenv:Header/>
        <soapenv:Body>
          <urn:timbrar_cfdi soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
            <username xsi:type=\"xsd:string\">#{ENV['wsdl_username']}</username>
            <password xsi:type=\"xsd:string\">#{ENV['wsdl_password']}</password>
            <sxml xsi:type=\"xsd:string\">#{encode_xml}</sxml>
          </urn:timbrar_cfdi>
        </soapenv:Body>
      </soapenv:Envelope>^

    client = Savon.client(wsdl: ENV['wsdl_url'], ssl_verify_mode: :none, log: :true, log_level: :debug)
    response = client.call(:timbrar_cfdi, { "xml" => envelope })
    return { response: response.to_hash, message: nil }
  end

  def self.evaluate_response

  end

end

