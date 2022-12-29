class EncryptData

  def self.encrypt(type)
    encrip = SymmetricEncryption.encrypt("#{type}-#{ (0...12).map { (65 + rand(26)).chr }.join }")
    return encrip.gsub('/', '')
  end

end