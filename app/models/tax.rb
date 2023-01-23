class Tax < ApplicationRecord

  def self.get_data_taxes(slug)
    return Tax.where(user_id: User.find_by(slug: slug))
              .select(:tax_key, :tax_name, :tax_rate, :status, :slug)
  end

  def self.insert_tax(params)
    unless exist_tax(params)
      data = {
        user_id: User.find_by(slug: params[:slugUser]).id,
        tax_key: CatTaxRange.find_by(id: params[:taxKey]).tax_type,
        tax_name: params[:taxName],
        tax_rate: params[:taxRate],
        status: 1,
        slug: EncryptData.encrypt("tax_result")
      }
      data = Tax.create(data)
      return { message: 'Este no se encuetra registrado este dato.', data: data }
    else
      return { message: 'Ya se encuentra registrado.', data: nil }
    end
  end

  def self.update_tax_status(slug)
    return Tax.find_by(slug: slug).destroy
  end

  def self.update_tax(params)
    unless exit_tax_for_update(params)
      tax = Tax.find_by(slug: params[:slugTax])
      tax.tax_rate = params[:taxRate]
      save_data = tax.save!
      return { save_data: save_data, result: tax, message: 'Este data no esta registrado' }
    else
      return { message: 'Ya se encuentra registrado.', save_data: false}
    end
  end

  def self.exist_tax(params)
    exit = false
    data = Tax.where(user_id: User.find_by(slug: params[:slugUser]).id)
              .where(tax_name: params[:taxName])
              .where(tax_rate: params[:taxRate])
    exit = true if data.count > 0
    return exit
  end

  def self.exit_tax_for_update(params)
    exit = false
    data = Tax.where(user_id: User.find_by(slug: params[:slugUser]).id)
              .where(tax_name: params[:taxName])
              .where(tax_rate: params[:taxRate])
              .where.not(slug: params[:slugTax])
    exit = true if data.count > 0
    return exit
  end

end