class MassiveDownloadMailer < ApplicationMailer

  def send_packages(request_id, packages, email, created_at, amount_packages)
    begin
      data = MassiveRequest.joins("inner join companies on companies.id = emitters.company_id")
                            .select('companies.razon_social').where("massive_requests.request_id_sat = '#{request_id}'")
                            .first
      @packages = packages
      @request_id = request_id
      @nombre = data.razon_social
      @created_at = created_at
      @amount_packages = amount_packages
      message = 'Envio de Paquetes de la Descarga Masiva'
      mail(:to => email, :subject => message)
    rescue Exception => e
      Rails.logger.debug("#{e.message}")
    end
  end



end