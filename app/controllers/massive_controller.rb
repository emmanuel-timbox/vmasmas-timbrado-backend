class MassiveController < ApplicationController

  # require 'validate_certificate_massive.rb'
  require 'massive_download_solicitud_worker.rb'
  # require 'validations_massive_download.rb'


  def create

    begin
      data = {}

      slug_user = params[:user_slug]
      slug_emitter = params[:slug_emitter]
      user_id = User.find_by(slug:slug_user).id
      emitter_id = Emitter.find_by(slug:slug_emitter).id

      if params['fechaIncial'].present?
        data['fechaIncial'] = params['fechaIncial']
      end
      if params['fechafinal'].present?
        data['fechafinal'] = params['fechafinal']
      end
      data['rfc_receptor'] = params['rfc_receptor']

      if params['rfc_receptor'].present?
        data['rfc_receptor'] = params['rfc_receptor']
      end

      if params['rfc'].present?
        data['rfc'] = params['rfc']
      end

      if params['tipo_so'].present?
        data['tipo_so'] = params['tipo_so']
      end

      if params['tipo_com'].present?
        data['tipo_com'] = params['tipo_com']
      end

      if params['tipo_com'].present?
        data['tipo_com'] = params['tipo_com']
      end
      if params['estado_com'].present?
        data['estado_com'] = params['estado_com']
      end

      if params['rfc_acuentaAterceros'].present?
        data['rfc_acuentaAterceros'] = params['rfc_acuentaAterceros']
      end
      data['correo'] = params['correo']
      # data['cer_file'] = params['cer_file']
      # data['key_file'] = params['key_file']
      data['password'] = params['password']


      massive_download = MassiveRequest
      validate_efirma = ValidateCertificateMassive::ValidateCertificateMassive.new(params['cer_file'], params['key_file'])
      validations = ValidationsMassiveRequest::ValidationsMassiveDownload
      if validate_efirma.validos?(data['password'])
        @certificate_info = validate_efirma.get_info
        validate_range_date = validations.validate_request_times(data['fechaIncial'], data['fechafinal'])
        if validate_range_date[:is_validate]
          validate_amount_request = massive_download.validate_amount_request(user_id)
          if validate_amount_request[:is_validate]

            data['certificate_pem'] = @certificate_info[:certificate_pem]
            data['key_pem'] = @certificate_info[:key_pem].to_s
            byebug
            massive_download_solicitud = MassiveDownloadSolicitudWorker.perform(data)
            if massive_download_solicitud[:is_accepted]
              TempFiel.insert_temp_fiel(@certificate_info[:certificate_pem], @certificate_info[:key_pem].to_s, user_id)
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
    company_id = params['company_id']
    result = MassiveRequest.select_requests(company_id)
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


  private def show_data(data)
    return {
      rfc: data[:rfc],
      curp: data[:curp],
      social_security_number: data[:social_security_number],
      work_start_date: data[:work_start_date],
      antiquity: data[:antiquity_e],
      type_contract: data[:type_contract],
      unionized: data[:unionized],
      type_working_day: data[:type_working_day],
      regime_type: data[:regime_type],
      employee_number: data[:employee_number],
      departament: data[:departament],
      risk_put: data[:risk_put_e],
      put: data[:put],
      payment_frequency: data[:payment_frequency],
      banck: data[:banck],
      banck_account: data[:banck_account],
      base_salary: data[:base_salary],
      daily_salary: data[:daily_salary],
      federative_entity_key: data[:federative_entity_key],
      slug: data[:slug]
    }
  end






end