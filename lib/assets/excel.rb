class Excel
  require 'roo'

  def self.readExcel(array_sheets, user_slug)
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
              #revisa si el empleado ya se encuentra registrado con el curp y no. de suguro social
              # con respecto a el receptor
              exist_employee = Employee.find_by(receiver_id: receiver[:id], curp: val[6], social_security_number: val[7])
              if exist_employee.nil?

                employee = Employee.insert_employee_by_excel(val, receiver[:id])
                if employee[:is_valid]
                  result.push(formatter_data_result(receiver, employee[:data]))
                else
                  message = employee[:errors][0]
                  message + ", #{employee[:errors][1]}" if employee[:errors].count == 2
                  errors.push({
                                data_row: "Fila afectada: #{val[1]}, RFC: #{val[2]}",
                                error_message: message
                              })
                  raise ActiveRecord::Rollback
                end

              else
                info.push({
                            data_row: "Fila afectada: #{index + 1}, RFC del Receptor: #{val[2]}",
                            info_message: 'Ya se encuentra registrado el Empleado.'
                          })
                next
              end
            end
          rescue
            errors.push({
                          data_row: "Fila afectada: #{index + 1}, RFC del Receptor: #{val[2]}",
                          error_message: 'Los datos de Empleado no se registraron.'
                        })
            next
          end
        end

        if exist_emitter.nil?
          info.push({
                        emisor: val[0],
                        data_row: "Fila afectada: #{val[1]}, RFC: #{val[2]}",
                        error_message: 'El Emisor no se encuentra registrado.'
                      })
          next
        end
      end

      return { data: result, errors: errors, info: info }
    rescue Exception => e
      return nil
    end
  end

  private

  def self.formatter_data_result(receiver, employee)
    return {
      name: receiver[:bussiness_name],
      rfc: receiver[:rfc],
      curp: employee[:curp],
      social_security_number: employee[:social_security_number],
      work_start_data: employee[:work_start_date],
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
      slug: employee[:slug]
    }
  end

end

