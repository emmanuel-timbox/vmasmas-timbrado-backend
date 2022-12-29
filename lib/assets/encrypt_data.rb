class EncryptData

  def self.encrypt(type)
    return SymmetricEncryption.encrypt("#{type}-#{ (0...12).map { (65 + rand(26)).chr }.join }")
  end

end