class Certificate < ApplicationRecord
  belongs_to :emitter_as_certficate, inverse_of: :certificate_as_emitter, class_name: 'Emitter', optional: true, autosave: true

  def self.get_certificate(slug_emitter)
    return Certificate.find_by(emitter_id: Emitter.find_by(slug: slug_emitter).id)
  end

  def self.insert_certificate(params)
    data = nil
    validate_cer = ValidateCertificate.new(params[:certificate])

    unless validate_cer.isValid
      error_message = validate_cer.get_error
      return { message: error_message, data: data }
    end

    indicted = validate_cer.get_info
    data = {
      emitter_id: Emitter.find_by(slug: params[:slugEmitter]).id,
      certificate_number: indicted[:certificate_number],
      rfc: indicted[:certificate_data][:local_rfc],
      identity: indicted[:certificate_data][:certificate_name],
      verified_by: indicted[:certificate_data][:verified_by],
      date_expiry: indicted[:date_expiry],
      certificate_pem: indicted[:certificate_pem],
      slug: EncryptData.encrypt('certificate_for_emitter')
    }

    return { message: nil, data: Certificate.create(data) }
  end

  def self.update_certificate(params)
    data = nil
    validate_cer = ValidateCertificate.new(params[:certificate])

    unless validate_cer.isValid
      error_message = validate_cer.get_error
      return { message: error_message, data: data }
    end

    destroy = Certificate.find_by(slug: params[:id]).destroy
    return { message: 'No se pudo remplazar el Certificado antiguo', data: nil } if destroy.nil?

    indicted = validate_cer.get_info
    data = {
      emitter_id: Emitter.find_by(slug: params[:slugEmitter]).id,
      certificate_number: indicted[:certificate_number],
      rfc: indicted[:certificate_data][:local_rfc],
      identity: indicted[:certificate_data][:certificate_name],
      verified_by: indicted[:certificate_data][:verified_by],
      date_expiry: indicted[:date_expiry],
      certificate_pem: indicted[:certificate_pem],
      slug: EncryptData.encrypt('certificate_for_emitter')
    }

    return { message: nil, data: Certificate.create(data) }
  end

end