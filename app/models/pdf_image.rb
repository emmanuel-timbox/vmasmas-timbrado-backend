class PdfImage < ApplicationRecord

  def self.get_images(slug)
    return PdfImage.find_by(emitter_id: Emitter.find_by(slug: slug).id)
  end

  def self.insert_images(data)
    begin
      return nil if data[:logo_image] == 'undefined' && data[:water_mark_image] == 'undefined'

      files_name = HelpersApp.save_pdf_images(data, false)
      path = "pdf_images_companies/#{data[:slug]}"
      pdf_images = {
        emitter_id: Emitter.find_by(slug: data[:slug]).id,
        slug: EncryptData.encrypt('pdf-images')
      }
      pdf_images[:logo_image_url] = "#{path}/#{files_name[:logo_image_name]}" if data[:logo_image] != 'undefined'
      pdf_images[:water_mark_image_url] = "#{path}/#{files_name[:water_mark_image_name]}" if data[:water_mark_image] != 'undefined'

      return PdfImage.create(pdf_images)
    rescue Exception => e
      return nil
    end
  end

  def self.update_images(data)
    begin
      return nil if data[:logo_image] == 'undefined' && data[:water_mark_image] == 'undefined'

      files_name = HelpersApp.save_pdf_images(data, true)
      path = "pdf_images_companies/#{data[:slug]}"
      logo_image_url = data[:logo_image] != 'undefined' ? "#{path}/#{files_name[:logo_image_name]}" : nil
      water_mark_image_url = data[:water_mark_image] != 'undefined' ? "#{path}/#{files_name[:water_mark_image_name]}" : nil

      pdf = PdfImage.find_by(slug: data[:pdf_image_slug])
      pdf[:logo_image_url] = logo_image_url if data[:logo_image] != 'undefined'
      pdf[:water_mark_image_url] = water_mark_image_url if data[:water_mark_image] != 'undefined'

      return pdf.save!
    rescue Exception => e
      return false
    end
  end

end