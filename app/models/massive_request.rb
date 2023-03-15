class MassiveRequest < ApplicationRecord

  def self.validate_amount_request(emmiter_id)
    is_validate = false
    data = { message: 'Por el momento no se puede realizar una solicitud ya que hay una activa', status: 500 }
    massive_download = MassiveRequest.where("emmiter_id = '#{emmiter_id}' and status in (1,2,3,7)").first
    if massive_download.nil?
      is_validate = true
      data = { message: 'Se puede realizar una solicitud en estos momentos', status: 200 }
    end
    return { is_validate: is_validate, data: data }
  end

  def self.select_requests(emmiter_id)
    packages = []
    data_active_request = massive_request.where("emmiter_id = '#{emmiter_id}' and status in (1,2,3,7,8)").first
    data = massive_request.select("request_id_sat, estatus, cantidad_paquetes, email, created_at")
                          .where("emmiter_id = #{emmiter_id}").order(created_at: :desc)
                          .first(5)
    if !data_active_request.nil?
      request_id = data_active_request.request_id_sat
      packages = MassiveDownloadPackage.select("paquete_id, rack_url").where("massive_download_id = '#{request_id}'")
    end
    return { mensage: "Lista de Solicitudes", result: data, status: 200, packages: packages }
  end

  def self.select_solicitud_fiel
    data_result = MassiveRequest.joins("inner join temp_fiels on temp_fiels.emmiter_id = massive_downloads.emmiter_id")
                                .select("temp_fiels.*, massive_requests.*").where("status in (1, 2)")
    return data_result
  end

  def self.update_status_cancel(request_id)
    massive_download = MassiveRequest.find_by(solicitud_id: request_id)
    massive_download.estatus = 9
    return massive_download.save!
  end


end