class User < ApplicationRecord

  validates :email, uniqueness: true
  validates :rfc, uniqueness: true
  def self.insert_user(data)
    user = {
      rfc: data[:rfc],
      name: data[:name],
      email: data[:email],
      encrypted_password: BCrypt::Password.create(data[:password]),
      status: 1,
      slug: EncryptData.encrypt('user-client')
    }
    result = User.create(user)
    errors = []
    errors.push('Email') if result.errors[:email].any?
    errors.push('RFC') if result.errors[:rfc].any?
    return {isValid: result.valid?, errors: errors}
  end



end