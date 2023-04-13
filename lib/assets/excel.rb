class Excel
  require 'roo'

  def self.read_excel(array_sheets, user_slug)
    begin
      result = []
      errors = []
      info = []
      general = array_sheets[0]

      general.drop(1).each_with_index do |val, index|
        exist_emitter = Emitter.select_emitter_by_rfc(val[0], user_slug)
        unless exist_emitter.nil?
          begin

            ActiveRecord::Base.transaction do
              receiver = Receiver.find_by(issuer_id: exist_emitter[:id], rfc: val[2])
              receiver = Receiver.insert_receiver_by_excel(val, exist_emitter[:id]) if receiver.nil?

              # validamos actualizamos los el status de que si es de nomina y actualizar el status.
              if receiver[:have_payrooll] == 0
                receiver[:have_payrooll] = 1
                receiver.save!
              end

              # revisa si el empleado ya se encuentra registrado con el curp y no. de suguro social
              # con respecto a el receptor
              exist_employee = Employee.find_by(receiver_id: receiver[:id], curp: val[6], social_security_number: val[7])
              if exist_employee.nil?

                employee = Employee.insert_employee_by_excel(val, receiver[:id])
                if employee[:is_valid]
                  result.push(formatter_data_result(receiver, employee[:data]))
                else
                  message = employee[:errors][0]
                  message += ". #{employee[:errors][1]}" if employee[:errors].count == 2
                  info.push({
                              data_row: "#{index + 2 }, Nombre de Receptor: #{val[1]}, RFC: #{val[2]}",
                              info_message: message
                            })
                  raise ActiveRecord::Rollback
                end

              else
                info.push({
                            data_row: "#{index + 2}, Nombre de Receptor: #{val[1]}, RFC: #{val[2]}",
                            info_message: 'Ya se encuentra registrado el Empleado.'
                          })
                next
              end
            end
          rescue
            errors.push({
                          data_row: "#{index + 2}, Nombre de Receptor: #{val[1]}, RFC: #{val[2]}",
                          error_message: 'Los datos de Empleado no se registraron. Alguno de los datos no cumplen con la estructura correcta.'
                        })
            next
          end
        end

        if exist_emitter.nil?
          info.push({
                      emisor: val[0],
                      data_row: "#{index + 2}, Nombre de Receptor: #{val[1]}, RFC: #{val[2]}",
                      info_message: 'El Emisor no se encuentra registrado.'
                    })
          next
        end
      end

      return { list_employees: result, errors: errors, info: info }
    rescue Exception => e
      return nil
    end
  end

  def self.update_employee(params)
    begin
      data = nil
      ActiveRecord::Base.transaction do
        receiver = Receiver.update_receiver_by_excel(params)
        employee = Employee.update_employee_by_excel(params)

        raise ActiveRecord::Rollback unless receiver[:save_data]
        raise ActiveRecord::Rollback unless employee[:save_data]

        data = formatter_data_result(receiver[:result], employee[:result])
      end
      return data
    rescue Exception => e
      return nil
    end
  end

  def self.update_status_employee(params)
    begin
      data = nil
      ActiveRecord::Base.transaction do
        employee = Employee.update_status_employee(params['slugEmployee'])
        receiver = Receiver.update_status_receiver(params['slugReceiver'])

        raise ActiveRecord::Rollback unless receiver[:save]
        raise ActiveRecord::Rollback unless employee[:save]

        data = formatter_data_result(receiver[:result], employee[:result])
      end
      return data

    rescue Exeption => e
      return nil
    end
  end

  private

  def self.formatter_data_result(receiver, employee)
    return {
      bussiness_name: receiver[:bussiness_name],
      rfc: receiver[:rfc],
      cfdi_use: receiver[:cfdi_use],
      receiving_tax_domicile: receiver[:receiving_tax_domicile],
      recipient_tax_regimen: receiver[:recipient_tax_regimen],
      slug_receiver: receiver[:slug],
      curp: employee[:curp],
      social_security_number: employee[:social_security_number],
      work_start_date: employee[:work_start_date],
      antiquity: employee[:antiquity],
      type_contract: employee[:type_contract],
      unionized: employee[:unionized],
      type_working_day: employee[:type_working_day],
      regime_type: employee[:regime_type],
      employee_number: employee[:employee_number],
      departament: employee[:departament],
      job: employee[:job],
      occupational_risk: employee[:occupational_risk],
      payment_frequency: employee[:payment_frequency],
      banck: employee[:banck],
      banck_account: employee[:banck_account],
      base_salary: employee[:base_salary],
      daily_salary: employee[:daily_salary],
      federative_entity_key: employee[:federative_entity_key],
      slug_employee: employee[:slug],
      id: nil,
      status: employee[:status]
    }
  end

end

