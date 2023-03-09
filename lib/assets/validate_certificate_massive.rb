module ValidateCertificateMassive

  require 'openssl'
  byebug
  class ValidateCertificateMassive

    ASN1_STRFLGS_ESC_MSB = 4

    def initialize(cer, key)
      @errors = "Hubo un error inesperado. Favor de intentarlo mas tarde."
      @cer_pem = self.parse_to_pem(cer.read, "CERTIFICATE")
      @key_pem = self.parse_to_pem(key.read, "ENCRYPTED PRIVATE KEY")
      @certificate = nil
      @no_certificate = nil
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

    def validos?(password)
      if !validar_llave_privada(password)
        return false
      end
      if !validar_fecha_certificado
        return false
      end
      if !validar_fiel_certificado
        return false
      end
      return true
    end


    def validar_llave_privada(password)
      key_encrypted = @key_pem
      #validacion llave PRivada
      begin
        private_key = OpenSSL::PKey::RSA.new(key_encrypted, password)
        certificate_pem = @cer_pem
      rescue => e
        @error = "La llave privada es invalida o la contraseña no coincide"
        return false
      end
      #se verifica que la llave privada este ligada al certificado.
      certificate = OpenSSL::X509::Certificate.new certificate_pem
      unless certificate.check_private_key(private_key)
        @error="La llave privada no corresponde a su certificado."
        return false
      end
      @key_pem = private_key
      @certificate = certificate
      true
    end


    def validar_fecha_certificado
      cer = @certificate
      before = cer.not_before
      after =  cer.not_after
      fecha = Time.now.to_time.utc
      if after - fecha > 0
        if fecha >= before
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

    def validar_fiel_certificado
      certificado = @certificate
      key_usage = nil
      certificado.extensions.each do |child|
        if child.to_s.match(/^(keyUsage{1}+.*)$/)
          key_usage = child.to_s
        end
      end
      key_usage.slice! "keyUsage = "
      arr_keys = key_usage.split(", ")
      if !(arr_keys.length >= 4)
        @error = "Por favor de utilizar sus archivos FIEL y no los archivos CSD."
        return false
      else
        @no_certificate = certificado.serial.to_s(16).scan(/\w/).select.each_with_index { |_, i| i.odd? }.join(",").gsub(",","")
        return true
      end
    end

    def get_rfc_certicado
      subject = @certificate.subject.to_s(OpenSSL::X509::Name::ONELINE & ~ASN1_STRFLGS_ESC_MSB).force_encoding("UTF-8")
      if subject.scan(/^.*UniqueIdentifier = ([a-zA-Z&Ñ]{3,4}\d{6}[A-Z0-9]{3}).*$/).count > 0
        rfc_local = subject.scan(/^.*UniqueIdentifier = ([a-zA-Z&Ñ]{3,4}\d{6}[A-Z0-9]{3}).*$/)[0][0]
        return rfc_local
      else
        @error = "El certificado FIEL no coorresponde al RFC #{@rfc}"
      end
    end

    def get_error
      return @error
    end

    def get_info
      @cer_hash = {
        :certificate_pem => @cer_pem,
        :key_pem => @key_pem,
        :no_certificado => @no_certificate,
        :rfc => get_rfc_certicado
      }
    end

  end

end