class Employee < ApplicationRecord
  def self.get_data_employee(slug_user)

    return Employee.where(user_id: User.find_by(slug: slug_user).id)
                   .select( :rfc,:curp,:social_security_number, :work_start_date, :antiquity, :type_contract,
                            :unionized, :type_working_day, :regime_type,:employee_number, :departament, :risk_put,:put,
                            :payment_frequency, :banck, :banck_account, :base_salary, :daily_salary, :federative_entity_key,
                            :slug)
  end

  def self.insert_employee(params)
    data = {
      rfc: params[:rfc],
      curp: params[:curp],
      social_security_number: params[:social_security_number],
      work_start_date: params[:work_start_date],
      antiquity: params[:antiquity_e],
      type_contract: params[:type_contract],
      unionized: params[:unionized],
      type_working_day: params[:type_working_day],
      regime_type: params[:regime_type],
      employee_number: params[:employee_number],
      departament: params[:departament],
      risk_put: params[:risk_put_e],
      put: params[:put],
      payment_frequency: params[:payment_frequency],
      banck: params[:banck],
      banck_account: params[:banck_account],
      base_salary: params[:base_salary],
      daily_salary: params[:daily_salary],
      federative_entity_key: params[:federative_entity_key],
    }
    return Employee.create(data)
  end

  def self.exist_rfc(rfc)
    exist = false
    employee = Employee.where(rfc: rfc)
    exist = true if employee.count > 0
    return { exist: exist, data: employee }
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