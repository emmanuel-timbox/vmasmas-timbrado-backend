class PdfImage < ApplicationRecord

  def self.get_images(slug)
    return PdfImage.find_by(emitter_id: Emitter.find_by(slug: slug).id)
  end

  def self.insert_images(data)
    begin
      return nil if data[:logo_image] == 'undefined' && data[:water_mark_image] == 'undefined'

      HelpersApp.save_pdf_images(data, false)
      path = "pdf_images_companies/#{data[:slug]}"
      pdf_images = {
        emitter_id: Emitter.find_by(slug: data[:slug]).id,
        slug: EncryptData.encrypt('pdf-images')
      }
      pdf_images[:logo_image_url] = "#{path}/#{data[:logo_image].original_filename}" if data[:logo_image] != 'undefined'
      pdf_images[:water_mark_image_url] = "#{path}/#{data[:water_mark_image].original_filename}" if data[:water_mark_image] != 'undefined'

      return PdfImage.create(pdf_images)
    rescue Exception => e
      return nil
    end
  end

  def self.update_images(data)
    begin
      return nil if data[:logo_image] == 'undefined' && data[:water_mark_image] == 'undefined'

      HelpersApp.save_pdf_images(data, true)
      path = "pdf_images_companies/#{data[:slug]}"
      logo_image_url = data[:logo_image] != 'undefined' ? "#{path}/#{data[:logo_image].original_filename}" : nil
      water_mark_image_url = data[:water_mark_image] != 'undefined' ? "#{path}/#{data[:water_mark_image].original_filename}" : nil

      return PdfImage.find_by(slug: data[:slug])
                     .update(logo_image_url: logo_image_url,
                             water_mark_image_url: water_mark_image_url)
    rescue Exception => e
      return false
    end
  end

end