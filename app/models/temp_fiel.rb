class TempFiel < ActiveRecord

  def self.insert_temp_fiel(cer, key, company_id)
    temp_fiel = TempFiel.new
    temp_fiel.company_id = company_id
    temp_fiel.fiel64 = cer
    temp_fiel.key64 = key
    temp_fiel.keep = 1
    temp_fiel.save!
  end

end