class TempFile < ApplicationRecord

  def insert_temp_file(cer, key, user_id,emitter_id)
    temp_fiel = TempFile.new
    temp_fiel.user_id = user_id
    temp_fiel.emmiter_id = emitter_id
    temp_fiel.fiel64 = cer
    temp_fiel.key64 = key
    temp_fiel.keep = 1
    temp_fiel.save!
  end
end