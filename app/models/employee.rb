class Employee < ApplicationRecord

  def self.get_data_employee(slug_user)
    return Employee.where(user_id: User.find_by(slug: slug_user).id)
                   .select( :rfc,:curp,:social_security_number, :work_start_date, :antiquity, :type_contract,
                            :unionized, :type_working_day, :regime_type,:employee_number, :departament, :risk_put,:put,
                            :payment_frequency, :banck, :banck_account, :base_salary, :daily_salary, :federative_entity_key,
                            :slug)
  end

  def self.insert_employee_by_excel(row, receiver_id)
    errors = []
    employee = {
      receiver_id: receiver_id,
      curp: row[6],
      social_security_number: row[7],
      work_start_date: row[8],
      antiquity: row[9],
      type_contract: row[10],
      unionized: row[11],
      type_working_day: row[12],
      regime_type: row[13],
      employee_number: row[14],
      departament: row[15],
      job: row[16],
      occupational_risk: row[17],
      payment_frequency: row[18],
      banck: row[19],
      banck_account: row[20],
      base_salary: row[21],
      daily_salary: row[22],
      federative_entity_key: row[23],
      status: 1,
      slug: EncryptData.encrypt('employee')
    }

    exist_curp = Employee.find_by(curp: row[6]).nil?
    exist_social_security_number = Employee.find_by(social_security_number: row[7]).nil?

    if !exist_curp || !exist_social_security_number
      errors.push("Ya se encuentra registrado un Empleado con este CURP: #{row[6]}") unless exist_curp
      errors.push("Ya se encuentra registrado un Empleado con este Numero de Seguro Socila: #{row[7]}") unless exist_social_security_number
      return {is_valid: false, errors: errors}
    end

    return {is_valid: true, data: Employee.create(employee) } if exist_curp && exist_social_security_number
  end

  def self.update_employee(data_employee)
    data = Employee.find_by(slug: data_employee[:id])
    data[:curp] = data_employee[:curp]
    data[:rfc] = data_employee[:rfc]
    data[:social_security_number] = data_employee[:social_security_number]
    data[:work_start_date] = data_employee[:work_start_date]
    data[:antiquity] = data_employee[:antiquity]
    data[:type_contract] = data_employee[:type_contract]
    data[:unionized] = data_employee[:unionized]
    data[:type_working_day] = data_employee[:type_working_day]
    data[:regime_type] = data_employee[:regime_type]
    data[:employee_number] = data_employee[:employee_number]
    data[:departament] = data_employee[:departament]
    data[:risk_put] = data_employee[:risk_put]
    data[:put] = data_employee[:put]
    data[:payment_frequency] = data_employee[:payment_frequency]
    data[:banck] = data_employee[:banck]
    data[:banck_account] = data_employee[:banck_account]
    data[:base_salary] = data_employee[:base_salary]
    data[:daily_salary] = data_employee[:daily_salary]
    data[:federative_entity_key] = data_employee[:federative_entity_key]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end

end