class CertificateController < ApplicationController

  def index
  end

  def show
    begin
      code = 500
      data = nil
      result = Certificate.get_certificate(params[:id])
      unless result.nil?
        code = 200
        data = data_formatter(result)
      end
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin
      code = 500
      data = nil
      certificate = Certificate.insert_certificate(params)
      unless certificate[:data].nil?
        code = 200
        data = data_formatter(certificate[:data])
      end
      render json: { code: code, data: data, message: certificate[:message] }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def update
    begin
      code = 500
      data = nil
      certificate = Certificate.update_certificate(params)
      unless certificate[:data].nil?
        code = 200
        data = data_formatter(certificate[:data])
      end
      render json: { code: code, data: data, message: certificate[:message] }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def destroy
    begin
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  private def data_formatter(data)
    return {
      certificate_number: data[:certificate_number],
      rfc: data[:rfc],
      identity: data[:identity],
      verified_by: data[:verified_by],
      date_expiry: data[:date_expiry],
      slug: data[:slug]
    }
  end

end