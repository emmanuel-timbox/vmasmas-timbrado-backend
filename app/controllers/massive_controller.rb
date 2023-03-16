class MassiveController < ApplicationController

  # require 'validate_certificate_massive.rb'
  require 'massive_download_solicitud_worker.rb'
  # require 'validations_massive_download.rb'

  def show
    begin
      result = MassiveRequest.get_data_employee(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end
  def create

    begin
      data = {}

      slug_user = params[:user_slug]
      slug_emitter = params[:slug_emitter]
      user_id = User.find_by(slug:slug_user).id
      data['user_id'] = User.find_by(slug:slug_user).id
      emmiter_id = Emitter.find_by(slug:slug_emitter).id
      data['emitter_id'] = Emitter.find_by(slug:slug_emitter).id

      if params['FechaInicial'].present?
        data['FechaInicial'] = params['FechaInicial']
      end

      if params['FechaFinal'].present?
        data['FechaFinal'] = params['FechaFinal']
      end

      if params['RfcReceptor'].present?
        data['RfcReceptor'] = params['RfcReceptor']
      end

      if params['rfc'].present?
        data['RfcEmisor'] = params['rfc']

      end

      if params['RfcSolicitante'].present?
        data['RfcSolicitante'] = params['RfcSolicitante']

      end

      if params['TipoSolicitud'].present?
        data['TipoSolicitud'] = params['TipoSolicitud']

      end

      if params['TipoComprobante'].present?
        data['TipoComprobante'] = params['TipoComprobante']
      end

      if params['EstadoComprobante'].present?
        data['EstadoComprobante'] = params['EstadoComprobante']
      end


      if params['RfcACuentaTerceros'].present?
        data['RfcACuentaTerceros'] = params['RfcACuentaTerceros']
      end

      if params['Complemento'].present?
        data['Complemento'] = params['Complemento']
      end

      data['correo'] = params['correo']
      data['password'] = params['password']

      massive_download = MassiveRequest
      validate_efirma = ValidateCertificateMassive::ValidateCertificateMassive.new(params['cer_file'], params['key_file'])
      validations = ValidationsMassiveRequest::ValidationsMassiveDownload
      if validate_efirma.validos?(data['password'])
        @certificate_info = validate_efirma.get_info
        validate_range_date = validations.validate_request_times(data['FechaInicial'], data['FechaFinal'])
        if validate_range_date[:is_validate]
          validate_amount_request = massive_download.validate_amount_request(emmiter_id)
          if validate_amount_request[:is_validate]
            data['certificate_pem'] = @certificate_info[:certificate_pem]
            data['key_pem'] = @certificate_info[:key_pem].to_s
            massive_download_solicitud = MassiveDownloadSolicitudWorker.perform(data)
            if massive_download_solicitud[:is_accepted]
              TempFile.new.insert_temp_file(data['certificate_pem'], data['key_pem'], user_id,emmiter_id)
              result = { message: "Se ha generado con éxito la Solicitud de Descarga Masiva con el siguiente ID #{massive_download_solicitud[:request_sat_id]}", status: 200 }
            else
              result = { message: 'Su solicitud no ha sido Aceptada', status: 500 }
            end
          else
            result = validate_amount_request[:data]
          end
        else
          result = validate_range_date[:data]
        end
      else
        result = { message: validate_efirma.get_error, estatus: 500 }
      end
    rescue Exception => e
      result = { message: e.message, estatus: 500 }
    end
    render json: result
  end

  def get_massive_request
    emmiter_id = params['emmiter_id']
    result = MassiveRequest.select_requests(emmiter_id)
    render json: result
  end

  def send_email
    begin
      request_id = params['request_id']
      email = params['email']
      amount_packages = params['amount_packages']
      created_at = params['created_at']
      packages = params['packages']
      if (amount_packages > 0)
        MassiveDownloadMailer.send_packages(request_id, packages, email, created_at, amount_packages).deliver_now
        data = { message: 'Se le envio un correo con el cual podra descargar los paquetes que resultarón de la descarga', status: 200 }
      else
        data = { message: 'Aun no se obtienen los paquetes de la descarga Masiva', status: 500 }
      end
      render json: data
    rescue Exception => e
      render json: { mensage: e.message }
    end
  end

  def cancel_request
    request_id = params['request_id']
    massive_download = MassiveRequest.update_status_cancel(request_id)
    if massive_download
      data = { massage: 'Se cancelo la solicitud', status: 200 }
    else
      data = { massage: 'No se pudo cancelar la solicitud', status: 500 }
    end
    render json: data
  end









end