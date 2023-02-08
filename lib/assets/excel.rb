class Excel

  require 'roo'

  def self. readExcel(array_sheets)
    result = []
    @general = array_sheets[0]

    # transaccion
    @general.drop(1).each_with_index do |val, index|

      receiver = {
        rfc: val[2],
        bussiness_name: val[20],
        cfdi_use: val[21],
        receiving_tax_domicile: val[22],
        recipient_tax_regimen: val[23],
        tax_id_number: val[24],
        tax_residence: val[25],
      }

      data_nomina = {
        curp: val[1],
        rfc: val[2],
        social_security_number: val[3],
        work_start_date: val[4],
        antiquity_e: val[5],
        type_contract: val[6],
        unionized: val[7],
        type_working_day:val[8],
        regime_type:val[9],
        employee_number:val[10],
        departament:val[11],
        put: val[12],
        risk_put_e:val[13],
        payment_frequency:val[14],
        banck:val[15],
        banck_account:val[16],
        base_salary:val[17],
        daily_salary:val[18],
        federative_entity_key:val[19]
      }
      rfcReceptor = {
        rfc_recep: val[0]
      }

      # hay que tomar el id del emisor
      emitter_data = Emitter.rfc_recep()
      byebug
      exist = Receiver.exist_rfc(val[2])
      # existcurp = Receiver.exist_curp ([0])

      if exist
        # si exist el rfc solo se tiene que guardar los de nomina
        employee = Employee.insert_employee(data_nomina)
        unless employee.nil?
          result.push(employee)
        end

      else
        #si no existe vas a guar el receptor y los valore de nomina


      end


    end

    # aqui termina
    return result
    # todos los emploeados que se guardaron en base de datoṣ

  end

end
