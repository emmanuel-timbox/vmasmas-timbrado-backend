class HelpersApp

  def self.save_pdf_images(data, is_update = nil)
    @path = "#{Rails.root}/public/pdf_images_companies/#{data[:slug]}"
    @files_name = { logo_image_name: '', water_mark_image_name: '' }

    if !is_update
      FileUtils.rm_rf(@path) if Dir.exist?(@path)
      Dir.mkdir(@path)
    end

    files = Dir.glob(File.join(@path, '**', '*')).select { |file| File.file?(file) }

    if data[:logo_image] != 'undefined'
      files.each { |file| File.delete(file) if File.basename(file).include?('logo_image') }
      name_file_split = data[:logo_image].original_filename.split('.')

      File.open("#{@path}/logo_image.#{name_file_split[1]}", "wb") do |f|
        f.write(data[:logo_image].read)
      end

      @files_name[:logo_image_name] = "logo_image.#{name_file_split[1]}"
    end

    if data[:water_mark_image] != 'undefined'
      files.each { |file| File.delete(file) if File.basename(file).include?('water_mark_image') }
      name_file_split = data[:water_mark_image].original_filename.split('.')

      File.open("#{@path}/water_mark_image.#{name_file_split[1]}", "wb") do |f|
        f.write(data[:water_mark_image].read)
      end

      @files_name[:water_mark_image_name] = "water_mark_image.#{name_file_split[1]}"
    end

    return @files_name
  end

end