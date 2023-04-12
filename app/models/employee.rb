class Employee < ApplicationRecord
  belongs_to :receiver, inverse_of: :employee_receiver, class_name: 'Receiver', optional: true, autosave: true

  def self.get_data_employee(slug_user)
    return Employee.where("emitters.user_id = #{User.find_by(slug: slug_user).id}")
                   .select("receivers.bussiness_name, receivers.rfc, receivers.cfdi_use, receivers.receiving_tax_domicile,
                            receivers.recipient_tax_regimen, receivers.slug as slug_receiver, employees.curp,
                            employees.social_security_number, employees.work_start_date, employees.antiquity,
                            employees.type_contract, employees.unionized, employees.type_working_day, employees.regime_type,
                            employees.employee_number, employees.departament, employees.job, employees.occupational_risk,
                            employees.payment_frequency, employees.banck, employees.banck_account, employees.base_salary,
                            employees.daily_salary, federative_entity_key, employees.slug as slug_employee, employees.status")
                   .joins(receiver: [:issuer])
  end

  def self.insert_employee_by_excel(row, receiver_id)
    errors = []
    employee = {
      receiver_id: receiver_id,
      curp: row[6],
      social_security_number: row[7],
      work_start_date: formart_date(row[8]),
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
      errors.push("Ya se encuentra registrado un Empleado con este Numero de Seguro social: #{row[7]}") unless exist_social_security_number
      return { is_valid: false, errors: errors }
    end

    return { is_valid: true, data: Employee.create(employee) } if exist_curp && exist_social_security_number
  end

  def self.update_employee_by_excel(data_employee)
    data = Employee.find_by(slug: data_employee[:slug_employee])
    data[:curp] = data_employee[:curp]
    data[:social_security_number] = data_employee[:social_security_number]
    data[:work_start_date] = data_employee[:work_start_date]
    data[:antiquity] = data_employee[:antiquity]
    data[:type_contract] = data_employee[:type_contract]
    data[:unionized] = data_employee[:unionized]
    data[:type_working_day] = data_employee[:type_working_day]
    data[:regime_type] = data_employee[:regime_type]
    data[:employee_number] = data_employee[:employee_number]
    data[:departament] = data_employee[:departament]
    data[:occupational_risk] = data_employee[:occupational_risk]
    data[:job] = data_employee[:job]
    data[:payment_frequency] = data_employee[:payment_frequency]
    data[:banck] = data_employee[:banck]
    data[:banck_account] = data_employee[:banck_account]
    data[:base_salary] = data_employee[:base_salary]
    data[:daily_salary] = data_employee[:daily_salary]
    data[:federative_entity_key] = data_employee[:federative_entity_key]
    save_data = data.save!
    return { save_data: save_data, result: data }
  end

  def self.update_status_employee(slug)
    employee = Employee.find_by(slug: slug)
    status_init = employee[:status]
    employee.status = 0 if status_init == 1
    employee.status = 1 if status_init == 0
    save = employee.save!
    return { save: save, result: employee }
  end

  private

  def self.formart_date(date_excel)
    miliseconds = (date_excel - (25567 + 2)) * 86400 * 1000
    seconds = (miliseconds / 1000).to_s
    return Date.strptime(seconds, '%s').strftime('%Y-%m-%d')
  end
end