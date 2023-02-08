class Excel

  require 'roo'

  def self. readExcel(array_sheets)
    result = []
    @general = array_sheets[0]

    # transaccion
    @general.drop(1).each_with_index do |val, index|

      byebug
      receiver = {
        rfc: val[1],
        bussiness_name: val[19],
        cfdi_use: val[20],
        receiving_tax_domicile: val[21],
        recipient_tax_regimen: val[22],
        tax_id_number: val[23],
        tax_residence: val[24],

      }

      data_nomina = {
        curp: val[0],
        rfc: val[1],
        social_security_number: val[2],
        work_start_date: val[3],
        antiquity: val[4],
        type_contract: val[5],
        unionized: val[6],
        type_working_day:val[7],
        regime_type:val[8],
        employee_number:val[9],
        departament:val[10],
        put: val[11],
        risk_put:val[12],
        payment_frequency:val[13],
        banck:val[14],
        banck_account:val[15],
        base_salary:val[16],
        daily_salary:val[17],
        federative_entity_key:val[18]
      }

      exist = Receiver.exist_rfc([1])
      # existcurp = Receiver.exist_curp ([0])

      if exist
        # solo se tiene que guardar los de nomina
        employee = Employee.insert_employee(data_nomina)
        unless employee.nil?
          result.push(employee)
        end

      else
        #vas a guar el receptor y los valore de nomina
        employee = Employee.insert_employee(data_nomina)
        unless employee.nil?
          result.push(employee)
        end

      end

      # result[index] = data_nomina

    #   if receiver.nil?
    #
    #
    #   end
    # else
    #
    #   end




    end

    # aqui termina
    return result
    # todos los emploeados que se guardaron en base de datoṣ

  end

end
