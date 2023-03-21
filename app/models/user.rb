class User < ApplicationRecord
  require 'securerandom'
  has_secure_password

  validates :email, uniqueness: true
  validates :rfc, uniqueness: true
  def self.insert_user(data)
    errors = []
    user = {
      rfc: data[:rfc],
      name: data[:name],
      email: data[:email],
      password: data[:password],
      status: 1,
      slug: EncryptData.encrypt('user-client')
    }
    result = User.create(user)
    errors.push('Email') if result.errors[:email].any?
    errors.push('RFC') if result.errors[:rfc].any?
    return {isValid: result.valid?, errors: errors}
  end

end