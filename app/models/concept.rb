class Concept < ApplicationRecord

  def self.get_data_concept(slug)
    return Concept.where(user_id: User.find_by(slug: slug).id)
                  .select(:product_key, :id_number, :unit_key,  :unit,
                          :description, :status, :tax_object, :slug)
  end

  def self.insert_concept(params)
    data = {
      user_id: User.find_by(slug: params[:slugUser]).id,
      product_key: params[:productKey],
      id_number: params[:idNumber],
      unit_key: params[:unitKey],
      unit: params[:unit],
      description: params[:description],
      tax_object: params[:taxObject],
      status: 1,
      slug: EncryptData.encrypt('concept')
    }
    return Concept.create(data)
  end

  def self.update_concept(data_concept)
    data = Concept.find_by(slug: data_concept[:id])
    data[:product_key] = data_concept[:productKey]
    data[:id_number] = data_concept[:idNumber]
    data[:unit_key] = data_concept[:unitKey]
    data[:unit] = data_concept[:unit]
    data[:description] = data_concept[:description]
    data[:tax_object] = data_concept[:taxObject]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end

  def self.update_status_concept(slug)
    concept = Concept.find_by(slug: slug)
    status_init = concept[:status]
    concept.status = 0 if status_init == 1
    concept.status = 1 if status_init == 0
    save = concept.save!
    return {save: save, result: concept}
  end

end
    