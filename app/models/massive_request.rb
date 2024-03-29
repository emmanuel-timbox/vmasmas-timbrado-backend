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
    data = massive_request.select("request_id_sat, status, cantidad_paquetes, email, created_at")
                          .where("emmiter_id = #{emmiter_id}").order(created_at: :desc)
                          .first(5)
    if !data_active_request.nil?
      request_id = data_active_request.request_id_sat
      packages = MassiveDownloadPackage.select("paquete_id, rack_url").where("massive_download_id = '#{request_id}'")
    end
    return { mensage: "Lista de Solicitudes", result: data, status: 200, packages: packages }
  end

  def self.select_solicitud_fiel
    data_result = MassiveRequest.joins("inner join temp_files on temp_files.request_id_sat = massive_requests.request_id_sat")
                                .select("temp_files.*, massive_requests.*").where("status in (1, 2)")
    return data_result
  end

  def self.update_status_cancel(request_id)
    massive_download = MassiveRequest.find_by(solicitud_id: request_id)
    massive_download.estatus = 9
    return massive_download.save!
  end

  def self.send_email
    package = []
    data_result = MassiveRequest.where("status = 8")
    data_result.each do |elements|
      temp = []
      data = MassiveDownloadPackage.select("paquete_id, rack_url").where("massive_download_id = '#{elements.request_id_sat}'")
      data.each do |ele|
        package_data = { "id" => nil, "paquete_id" => ele.paquete_id, "rack_url" => ele.rack_url }
        temp.push([package_data])
      end
      package.push([temp, elements])
    end
    return package

  end

  def self.send_package(request_id)
    inner_join = "inner join massive_download_packages ON massive_requests.request_id_sat = massive_download_packages.massive_download_id"
    select_items = "massive_download_packages.rack_url"
    where_condition = "massive_requests.request_id_sat  = '#{request_id}'"

    packages = MassiveRequest.joins(inner_join).select(select_items).where(where_condition)
    return packages
    # SELECT massive_download_packages.rack_url
    # FROM massive_requests
    # JOIN massive_download_packages ON massive_requests.request_id_sat = massive_download_packages.massive_download_id
    # WHERE massive_requests.request_id_sat = '6606f62e-81e2-41e8-b6e4-153e4f442c51';
  end

  def self.get_data_massive(slug_user)
    return MassiveRequest.where(user_id: User.find_by(slug: slug_user).id)
                         .select(:emitter_rfc, :request_id_sat, :status, :email,
                                 :cantidad_paquetes, :created_at, :slug)
  end

  def self.insert_massive_request(params, request_id_sat, user_id, emitter_id, email)
    data = {
      request_id_sat: request_id_sat,
      user_id: user_id,
      emmiter_id: emitter_id,
      receive_rfc: params[:RfcSolicitante],
      emitter_rfc: params[:RfcEmisor],
      start_date: params[:FechaInicial],
      final_date: params[:FechaFinal],
      email: email,
      slug: EncryptData.encrypt("massive_request_donwload"),
      status: 1
    }
    massive_requesst = MassiveRequest.new(data)

    return { is_accepted: false } unless massive_requesst.save!

    return { is_accepted: true, request_sat_id: request_id_sat, data: massive_requesst }
  end

  def self.update_state_massive_request(request_id, status_state_code)
    massive_download = MassiveRequest.find_by(request_id_sat: request_id)

    massive_download.status = '5-3' if status_state_code == '5003'
    massive_download.status = '0-4' if status_state_code == '5004'
    massive_download.status = '5' if status_state_code == '5005'

    massive_download.save!
    return massive_download
  end

  def self.update_code_status(request_id, status_code)
    massive_download = MassiveRequest.find_by(request_id_sat: request_id)

    if status_code == '304'
      massive_download.status = '4'
      massive_download.save!
    end

    if status_code == '5004'
      massive_download.status = '0'
      massive_download.save!
    end

    return massive_download
  end

end