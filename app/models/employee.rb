class Employee < ApplicationRecord
  byebug
  def self.get_data_employee(slug_user)
    byebug
    return Employee.where(user_id: User.find_by(slug: slug_user).id)
                  .select( :rfc )
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


  # def self.exist_curp(curp)
  #   exist = false
  #   employee = Employee.find_by(curp: curp)
  #   exit = true unless employee.nil?
  #   return exist
  # end





end