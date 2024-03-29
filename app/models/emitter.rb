class Emitter < ApplicationRecord

  has_many :certificate_as_emitter, inverse_of: :emitter_as_certficate, foreign_key: :emitter_id, class_name: 'Certificate'
  has_many :xml_file_as_emitter, inverse_of: :emitter_as_xml_file, foreign_key: :emitter_id, class_name: 'XmlFile'
  has_many :receiver_emitter, inverse_of: :emitter_as_receiver, foreign_key: :issuer_id, class_name: 'Receiver'

  validates :rfc, uniqueness: { scope: :user_id, message: 'ya se encuentra registrado.' }

  def self.get_data_emmiter(slug_user)
    return Emitter.where(user_id: User.find_by(slug: slug_user))
                  .select(:bussiness_name, :rfc, :expedition_place,
                          :tax_regime, :status, :slug, :address, :company_name)
  end

  def self.get_data_emmiter_xml(slug_user)
    return Emitter.where(user_id: User.find_by(slug: slug_user), status: 1)
                  .select("emitters.bussiness_name , emitters.rfc,
       emitters.expedition_place, emitters.tax_regime, emitters.company_name,
       emitters.slug, emitters.address, certificates.slug as slug_certificate,
       certificates.certificate_number").left_joins(:certificate_as_emitter)
  end

  def self.select_emitter_by_rfc(rfc, user_slug)
    return Emitter.find_by(rfc: rfc, user_id: User.find_by(slug: user_slug).id)
  end

  def self.insert_people_tax(params)
    data = {
      user_id: User.find_by(slug: params[:slugUser]).id,
      bussiness_name: params[:bussinessName],
      rfc: params[:rfc],
      expedition_place: params[:expeditionPlace],
      tax_regime: params[:taxRegime],
      address: params[:address],
      company_name: params[:companyName],
      status: 1,
      slug: EncryptData.encrypt('emitter')
    }
    emitter = Emitter.new(data)

    return emitter.save! ? emitter : nil
  end

  def self.update_status_emitter(slug)
    emitter = Emitter.find_by(slug: slug)
    status_init = emitter[:status]
    emitter.status = 0 if status_init == 1
    emitter.status = 1 if status_init == 0
    save = emitter.save!
    return { save: save, result: emitter }
  end

  def self.update_emitter(data_emitter)
    data = Emitter.find_by(slug: data_emitter[:id])
    data[:bussiness_name] = data_emitter[:bussinessName]
    data[:rfc] = data_emitter[:rfc]
    data[:expedition_place] = data_emitter[:expeditionPlace]
    data[:tax_regime] = data_emitter[:taxRegime]
    data[:address] = data_emitter[:address]
    data[:company_name] = data_emitter[:companyName]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end

end
