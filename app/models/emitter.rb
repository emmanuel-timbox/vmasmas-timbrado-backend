class Emitter < ApplicationRecord

  def self.get_data_emmiter(slug_user)
    return Emitter.where(user_id: User.find_by(slug: slug_user))
                  .select(:bussiness_name, :rfc, :expedition_place,
                          :tax_regime, :status, :slug)
  end

  def self.insert_people_tax(params)
    data = {
      user_id: User.find_by(slug: params[:slugUser]).id,
      bussiness_name: params[:bussinessName],
      rfc: params[:rfc],
      expedition_place: params[:expeditionPlace],
      tax_regime: params[:taxRegime],
      status: 1,
      slug: EncryptData.encrypt('emitter')
    }
    return Emitter.create(data)
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
    return Emitter.find_by(slug: data_emitter[:slug])
                  .update({
                            bussiness_name: data_emitter[:bussinessName],
                            rfc: data_emitter[:rfc],
                            expedition_place: data_emitter[:expeditionPlace],
                            tax_regime: data_emitter[:taxRegimen]
                          })
  end

end
