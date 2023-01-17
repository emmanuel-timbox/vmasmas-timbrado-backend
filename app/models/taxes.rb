class Tax < ApplicationRecord

  def self.get_data_taxes(slug)
    return Tax.where()
  end

  def self.insert_tax(params)
    cat_tax = CatTaxRange.find(params[:taxKey])
    data = {

    }
  end

end