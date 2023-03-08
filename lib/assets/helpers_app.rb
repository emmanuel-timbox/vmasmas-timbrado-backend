class HelpersApp

  def self.save_pdf_images(data, is_update = nil)
    path = "#{Rails.root}/public/pdf_images_companies/#{data[:slug]}"
    FileUtils.rm_rf(path) if Dir.exist?(path)
    Dir.mkdir(path)

    if data[:logo_image] != 'undefined'

      # file = data[:logo_image]
      # if

      File.open("#{path}/#{data[:logo_image].original_filename}", "wb") do |f|
        f.write(data[:logo_image].read)
      end
    end

    if data[:water_mark_image] != 'undefined'
      File.open("#{path}/#{data[:water_mark_image].original_filename}", "wb") do |f|
        f.write(data[:water_mark_image].read)
      end
    end
  end

end