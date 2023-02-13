class Receiver < ApplicationRecord

  def self.get_data_receiver(slug)
    return Receiver.where(issuer_id: Emitter.find_by(slug: slug).id)
                   .select(:bussiness_name, :rfc, :cfdi_use, :receiving_tax_domicile, :status,
                           :slug, :recipient_tax_regimen, :tax_id_number, :recipient_tax_regimen, :tax_residence,
                           :receiving_tax_domicile)
  end

  def self.get_receiver_for_emitter(slug)

  end

  def self.insert_receiver(params)
    data = {
      issuer_id: Emitter.find_by(slug: params[:slugEmitter]).id,
      rfc: params[:rfc],
      bussiness_name: params[:bussinessName],
      cfdi_use: params[:cfdiUse],
      receiving_tax_domicile: params[:receivingTaxDomicile],
      recipient_tax_regimen: params[:recipientTaxRegimen],
      tax_id_number: params[:taxIdNumber],
      tax_residence: params[:tax_residence],
      status: 1,
      slug: EncryptData.encrypt('receiver')
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
    data[:cfdi_use] = data_receiver[:cfdiUse]
    data[:receiving_tax_domicile] = data_receiver[:receivingTaxDomicile]
    data[:recipient_tax_regimen] = data_receiver[:recipientTaxRegimen]
    data[:tax_id_number] = data_receiver[:taxIdNumber]
    data[:tax_residence] = data_receiver[:tax_residence]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end


  def self.exist_rfc(rfc)
    exist = false
    receiver = Receiver.where(rfc: rfc)
    exist = true if receiver.count > 0
    return { exist: exist, data: receiver }
  end

  def self.insert_receiver_excel(params)
    data = {
      issuer_id: Emitter.find_by(slug: params[:slugEmitter]).id,
      rfc: params[:rfc],
      bussiness_name: params[:bussinessName],
      cfdi_use: params[:cfdiUse],
      receiving_tax_domicile: params[:receivingTaxDomicile],
      recipient_tax_regimen: params[:recipientTaxRegimen],
      tax_id_number: params[:taxIdNumber],
      tax_residence: params[:tax_residence],
      status: 1,
      slug: EncryptData.encrypt('receiver')
    }
    return Receiver.create(data)
  end



end
  