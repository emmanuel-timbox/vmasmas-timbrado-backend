class Excel

  require 'roo'

  def self.readExcel(array_sheets, user_slug)
    result = []
    @general = array_sheets[0]

    # transaccion
    @general.drop(1).each_with_index do |val, index|

      receiver = {
        rfc: val[0],
        bussiness_name: val[20],
        cfdi_use: val[21],
        receiving_tax_domicile: val[22],
        recipient_tax_regimen: val[23],
        tax_id_number: val[24],
        tax_residence: val[25],
        status: 1,
        have_payroll: 0,
        slug: EncryptData.encrypt('receiver-nomina')
      }

      data_nomina = {
        user_id: User.find_by(slug: user_slug).id,
        curp: val[1],
        rfc: val[2],
        social_security_number: val[3],
        work_start_date: val[4],
        antiquity: val[5],
        type_contract: val[6],
        unionized: val[7],
        type_working_day:val[8],
        regime_type:val[9],
        employee_number:val[10],
        departament:val[11],
        put: val[12],
        risk_put:val[13],
        payment_frequency:val[14],
        banck:val[15],
        banck_account:val[16],
        base_salary:val[17],
        daily_salary:val[18],
        federative_entity_key:val[19],
        status: 1,
        slug: EncryptData.encrypt('employee')
      }

      receiver_existEmployees = Employee.exist_rfc(val[0])
      receiver_exist = Receiver.exist_rfc(val[0])

      if receiver_exist[:exist]
        data = Employee.create(data_nomina)
        result.push(data) unless data.nil?
      else
        data_receiver = Receiver.create(receiver)
        unless data_receiver.nil?
          data_employee = Employee.create(data_nomina)
          unless data_employee.nil?
            receiver.merge(data_nomina)
            result.push(data_receiver)
          end
        end

      end

    end

    # aqui termina
    return result
    # todos los emploeados que se guardaron en base de datoṣ

  end

end
