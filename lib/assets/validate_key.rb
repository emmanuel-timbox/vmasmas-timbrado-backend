class ValidateKey

  def initialize(password, key_file, certificate_pem)
    @password = password
    @key_pem = parse_to_pem(key_file.read, 'ENCRYPTED PRIVATE KEY')
    @certificate_pem = certificate_pem
  end

  private def parse_to_pem(content, tag)
    content = Base64.strict_encode64(content)
    arr = content.chars.each_slice(64).map(&:join)
    pem = "-----BEGIN #{tag}-----\n"
    arr.each do |c|
      pem = pem + c + "\n"
    end
    pem = pem + "-----END #{tag}-----\n"
    return pem
  end

  def check_key
    message = 'El certificado y su llave son validos.'
    is_valid = true

    begin
      private_ssl = OpenSSL::PKey::RSA.new(@key_pem, @password)
    rescue Exception => e
      is_valid = false
      message = 'La llave privada es invalida o la contraseña no coincide.'
      return { message: message, is_valid: is_valid }
    end

    certificate_ssl = OpenSSL::X509::Certificate.new @certificate_pem
    unless certificate_ssl.check_private_key(private_ssl)
      is_valid = false
      message = 'La llave privada no corresponde a su certificado.'
    end

    return { message: message, is_valid: is_valid }
  end

end