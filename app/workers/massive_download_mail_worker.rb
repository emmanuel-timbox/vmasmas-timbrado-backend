class MassiveDownloadMailWorker

  def perform
    begin
      i = 0
      massive_download = MassiveRequest.send_email
      massive_download.each do |request|
        download = request[1]
        rackpace = request[0]
        MassiveDownloadMailer.send_packages(download.request_id_sat, rackpace, download.email, download.created_at, download.cantidad_paquetes).deliver
        download.status = 10
        if download.save!
          i + 1
        end
      end
      Rails.logger.debug("Correo exitoso")

    rescue Exception => e
      return nil
    end

  end

end