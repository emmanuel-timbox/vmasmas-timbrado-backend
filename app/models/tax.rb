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
      return Tax.create(data)
    else

    end

  end

  def self.update_tax_status(slug)
    return Tax.find_by(slug: slug).destroy
  end

  def self.exist_tax(params)
    exit = false
    data = Tax.where(user_id: User.find_by(slug: params[:slugUser]).id,
                     tax_name: params[:taxName], tax_rate: params[:taxRate])
    exit = true if data.count > 0
    return exit
  end

end