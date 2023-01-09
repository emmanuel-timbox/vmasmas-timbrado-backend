class Concept < ApplicationRecord

    def self.get_data_concept(slug)

      return Concept.where(User_id: User.find_by(slug: slug).id)
                     .select(
                      :product_key,
                      :id_number,
                      :unit_key,
                      :unit,
                      :description,
                      :tax_object,
                      :slug
                      )
    end
  
    def self.get_receiver_for_concept(slug)
  
    end
  
    def self.insert_concept(params)
     
      data = {
        # user_id: Concept.find_by(slug: params[:slugConcept]).id,
        user_id: 2,
        product_key:  params[:productKey],
        id_number:  params[:idNumber],
        unit_key: params[:unitKey],
        unit:  params[:unit],
        description:  params[:description],
        tax_object:  params[:taxObject],
        slug: EncryptData.encrypt('concept')
      }
      return Concept.create(data)
    end
  
    
  
    def self.update_concept(data_concept)
      data = Concept.find_by(slug: data_concept[:id])
      data[:product_key] = data_concept[:product_key]
      data[:id_number] = data_concept[:id_number]
      data[:unit_key] = data_concept[:unit_key]
      data[:unit] = data_concept[:unit]
      data[:description] = data_concept[:description]
      data[:tax_object] = data_concept[:tax_object]
      save_data = data.save!
      return { save_data: save_data, result: data }
    end
  
  end
    