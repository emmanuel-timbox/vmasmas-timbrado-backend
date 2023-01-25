class ValidateCertificate

  ASN1_STRFLGS_ESC_MSB = 4

  def initialize(certificate)
    @errors = "Hubo un error inesperado. Favor de intentarlo mas tarde."
    @pem_certificate = parse_to_pem(certificate.read, "CERTIFICATE")
  end

  def isValid
    return false unless validar_date_certificate
    return false unless validar_csd_certificate
    return true
  end

  def parse_to_pem(content, tag)
    content = Base64.strict_encode64(content)
    arr = content.chars.each_slice(64).map(&:join)
    pem = "-----BEGIN #{tag}-----\n"
    arr.each do |c|
      pem = pem + c + "\n"
    end
    pem = pem + "-----END #{tag}-----\n"
    return pem
  end

  def validar_date_certificate
    @certificate = OpenSSL::X509::Certificate.new @pem_certificate
    cer = @certificate
    before = cer.not_before
    after = cer.not_after
    date = Time.now.to_time.utc
    if after - date > 0
      if date >= before
        @date_expiry = after
        return true
      else
        @error = "Su Certificado no se encuentra vigente, favor de verificarlo."
        return false
      end
    else
      @error = "Su Certificado no se encuentra vigente, favor de verificarlo."
      return false
    end
  end

  def validar_csd_certificate
    cer = @certificate
    key_usage = nil
    cer.extensions.each do |child|
      if child.to_s.match(/^(keyUsage{1}+.*)$/)
        key_usage = child.to_s
      end
    end

    key_usage.slice! "keyUsage = "
    arr_keys = key_usage.split(", ")
    if (arr_keys.length > 2)
      @error = "Por favor de utilizar sus archivos CSD y no los archivos FIEL."
      return false
    else
      @no_certificate = cer.serial.to_s(16).scan(/\w/).select.each_with_index { |_, i| i.odd? }.join(",").gsub(",", "")
      return true
    end
  end

  def get_rfc_certificate
    subject = @certificate.subject.to_s(OpenSSL::X509::Name::ONELINE & ~ASN1_STRFLGS_ESC_MSB).force_encoding("UTF-8")
    issuer = @certificate.issuer.to_s(OpenSSL::X509::Name::ONELINE & ~ASN1_STRFLGS_ESC_MSB).force_encoding("UTF-8")
    if subject.scan(/^.*UniqueIdentifier = ([a-zA-Z&Ñ]{3,4}\d{6}[A-Z0-9]{3}).*$/).count > 0
      return {
        local_rfc: subject.scan(/^.*UniqueIdentifier = ([a-zA-Z&Ñ]{3,4}\d{6}[A-Z0-9]{3}).*$/)[0][0],
        certificate_name: subject.scan(/CN = (.*?), name/)[0][0],
        verified_by: issuer.scan(/CN = (.*?), O =/)[0][0]
      }
    else
      return nil
    end
  end

  def get_error
    return @error
  end

  def get_info
    return @cer_hash = {
      certificate_pem: @pem_certificate,
      certificate_number: @no_certificate,
      date_expiry: @date_expiry,
      certificate_data: get_rfc_certificate
    }
  end

end

