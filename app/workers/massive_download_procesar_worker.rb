class MassiveDownloadProcesarWorker

  def self.perform
    begin
      # Hay que crear un cliente de rackspace
      @client = Fog::Storage.new(
        :provider => 'rackspace',
        :rackspace_username => ENV['rackspace_username'],
        :rackspace_api_key => ENV['rackspace_api_key'],
        :rackspace_region => 'IAD',
        :rackspace_cdn_ssl => true
      )
      request_downloads = MassiveRequest.where("status = '7'")
      request_downloads.each do |request|
        path = "#{Rails.root}/vendor/descarga_masiva/paquetes/#{request.request_id_sat}"
        files = Dir.glob(File.join(path, '**', '*')).select { |file| File.file?(file) }
        files.each do |package_zip|
          if File.exist?(package_zip)
            directory = @client.directories.new(:key => 'descarga_masiva_prd')
            folder = request.request_id_sat.split('-').last()
            package_name_zip = package_zip.split('/').last()
            package_id = package_name_zip.split('.').first()
            file = directory.files.create(
              :key => "#{folder}/#{package_name_zip}",
              :body => File.open(package_zip).read,
              :public => true
            )
            if (file.save)
              package = MassiveDownloadPackage.find_by(paquete_id: package_id)
              package.rack_url = file.public_url
              package.estatus = 2
              package.save
              File.delete(package_zip) if File.exist?(package_zip)
            else
              #aqui es donde guardadmos el log en caso de que el archivo no se puede subir a rackspace
              log(package_id, 5011, request.id)
            end
          else
            # aqui va el log en caso de que el archivo no fue encontrado en el disco duro
            log(package_id, 5010, request.id)
          end
        end
        all_packages_unpload = MassiveDownloadPackage.new.all_packages_unpload(request.request_id_sat)
        if all_packages_unpload
          #tambien hay que eliminar la fiel que se ocupo en este proceso
          temp_fiel = TempFile.find_by(request_id_sat: request.request_id_sat)
          next if temp_fiel.nil?
          temp_fiel.destroy
          path = "#{Rails.root}/vendor/descarga_masiva/paquetes/#{request.request_id_sat}"
          FileUtils.remove_dir(path) if File.directory?(path)
          request.status = "8"
          request.save!
        end
      end
    rescue => e
      ExceptionNotifier.notify_exception(e, :data => { :message => "Error en el MassiveDownloadProcesarWorker: #{e.backtrace}" })
      raise e
    end
  end

  def self.log(package_id, code, solicitud_id)
    log = MassiveDownloadLog.new
    log.salicitud_id = solicitud_id
    log.worker = 'UploadRackspace'
    log.error_code = code
    if code == 5010
      log.message = "El paquete #{package_id} no fue encontrado en el disco"
    else
      log.message = "El paquete #{package_id} no fue posible subir el archivo a RackSpace"
    end
    log.save!
  end


end