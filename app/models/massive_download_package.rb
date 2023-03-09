class MassiveDownloadPackage < ActiveRecord

  def self.select_package_process(request_id)
    inner_join = "inner join massive_request on massive_request.request_id_sat = massive_download_packages.massive_download_id
      inner join temp_fiels on temp_fiels.user_id = massive_request.user_id"
    select_items = "massive_download_packages.*, massive_request.request_id_sat, massive_downloads.receive_rfc,
        temp_fiels.fiel64, temp_fiels.key64"
    where_condition = "massive_download_packages.estatus = 0 and massive_download_packages.descargado = 0
        and massive_download_packages.massive_download_id = '#{request_id}'"
    packages = MassiveDownloadPackage.joins(inner_join).select(select_items).where(where_condition)
    return packages
  end

  def self.is_change_estatus_request(request_id)
    packages_for_request = MassiveDownloadPackage.select("estatus").where("massive_download_id = '#{request_id}' ")
    count = 0
    packages_for_request.each do |paquete|
      if paquete.estatus == '0'
        count += 1
      end
    end
    all_downloads =  count == 0 ? true : false
    return all_downloads
  end

  def self.all_packages_unpload(request_id)
    packages_for_request = MassiveDownloadPackage.select("estatus").where("massive_download_id = '#{request_id}' ")
    count = 0
    packages_for_request.each do |paquete|
      if paquete.estatus == '0' || paquete.estatus == '1'
        count += 1
      end
    end
    all_downloads =  count == 0 ? true : false
    return all_downloads
  end

end