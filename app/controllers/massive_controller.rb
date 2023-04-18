class MassiveController < ApplicationController

  # require 'validate_certificate_massive.rb'
  require 'massive_download_solicitud_worker.rb'
  # require 'validations_massive_download.rb'

  def create
    begin
      user_id = User.find_by(slug: params[:slugUser]).id
      emitter_id = Emitter.find_by(slug: params[:slugEmitter]).id
      massive_download = MassiveRequest
      validations = MassiveRequestHelper

      # validacion de certificado o firma
      validate_efirma = ValidateCertificateMassive.new(params['cerFile'], params['keyFile'])
      unless validate_efirma.validos?(params['password'])
        raise StandardError, validate_efirma.get_error
      end

      # validacion de rango de la fecha
      validate_range_date = validations.validate_request_times(params['fechaInicial'], params['fechaFinal'])
      unless validate_range_date[:is_validate]
        raise StandardError, validate_range_date[:data][:message]
      end

      # validacion de que no contenga una solicitud abierta el emisor
      validate_amount_request = massive_download.validate_amount_request(emitter_id)
      unless validate_amount_request[:is_validate]
        raise StandardError, validate_amount_request[:data][:message]
      end

      @certificate_info = validate_efirma.get_info
      key_pem = @certificate_info[:key_pem].to_s
      certificate_pem = @certificate_info[:certificate_pem]
      data = formatter_data_attr_request(params, certificate_pem, key_pem)
      massive_download_solicitud = MassiveDownloadSolicitudWorker.perform(data, user_id, emitter_id, params[:correo])

      if massive_download_solicitud[:is_accepted]
        TempFile.new.insert_temp_file(certificate_pem, key_pem, user_id, emitter_id, massive_download_solicitud[:request_sat_id])
        result = {
          message: "Se ha generado con éxito la Solicitud de Descarga Masiva con el siguiente ID #{massive_download_solicitud[:request_sat_id]}",
          code: 200,
          data: data_formatter(massive_download_solicitud[:data])
        }
      else
        result = { message: 'Su solicitud no ha sido Aceptada', code: 500 }
      end

      render json: result
    rescue Exception => e
      render json: {message: e.message, code: 500}
    end
  end

  def show_packages
    begin
      result = MassiveRequest.send_package(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def show
    begin
      result = MassiveRequest.get_data_massive(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  private def formatter_data_attr_request(params, certificate_pem, key_pem)
    data = {
      FechaInicial: params[:fechaInicial],
      FechaFinal: params[:fechaFinal],
      RfcReceptor: params[:rfcReceptor],
      RfcEmisor: params[:rfc],
      RfcSolicitante: params[:rfcSolicitante],
      TipoSolicitud: params[:tipoSolicitud],
      certificate_pem: certificate_pem,
      key_pem: key_pem
    }

    data[:Complemento] = params[:complemento] if params[:complemento] != ''
    data[:EstadoComprobante] = params[:estadoComprobante] if params[:estadoComprobante] != ''
    data[:RfcACuentaTerceros] = params[:rfcACuentaTerceros] if params[:rfcACuentaTerceros] != ''
    data[:TipoComprobante] = params[:tipoComprobante] if params[:tipoComprobante] != ''

    return data
  end

  private def data_formatter(data)
    return {
      cantidad_paquetes: data[:cantidad_paquetes],
      created_at: data[:created_at],
      email: data[:email],
      emitter_rfc: data[:emitter_rfc],
      request_id_sat: data[:request_id_sat],
      slug: data[:slug],
      status: data[:status],
    }
  end
end