class Receiver < ApplicationRecord

  def self.get_data_receiver(slug_user)
    return Receiver.where(issuer_id: User.find_by(slug: slug_user))
                   .select(
                     :bussiness_name,
                     :rfc,
                     :cfdi_use,
                     :receiving_tax_domicile,
                     :status,
                     :slug,
                     :recipient_tax_regimen,
                     :tax_id_number,
                     :recipient_tax_regimen,
                     :tax_residence,
                     :receiving_tax_domicile,

                   )
  end

  def self.insert_receiver(params)
    data = {
      issuer_id: User.find_by(slug: params[:slugUser]).id,
      rfc: params[:rfc],
      bussiness_name: params[:bussinessName],
      cfdi_use: params[:cfdiUse],
      receiving_tax_domicile: params[:receivingTaxDomicile],
      recipient_tax_regimen: params[:recipientTaxRegimen],
      tax_id_number: params[:taxIdNumber],
      tax_residence: params[:tax_residence],
      status: 1,
      slug: EncryptData.encrypt('emitter')
    }

    return Receiver.create(data)
  end

  def self.update_status_receiver(slug)
    receiver = Receiver.find_by(slug: slug)
    status_init = receiver[:status]
    receiver.status = 0 if status_init == 1
    receiver.status = 1 if status_init == 0
    save = receiver.save!
    return { save: save, result: receiver }
  end

  def self.update_receiver(data_receiver)
    data = Receiver.find_by(slug: data_receiver[:id])
    data[:bussiness_name] = data_receiver[:bussinessName]
    data[:rfc] = data_receiver[:rfc]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end

end
  