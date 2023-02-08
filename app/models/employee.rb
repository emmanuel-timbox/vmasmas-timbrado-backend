class Employee < ApplicationRecord




  def self.insert_employee(params)
    data = {
      rfc: params[:rfc],
      bussiness_name: params[:bussinessName],
      curp: params[:curp],
      social_security_number: params[:social_security_number],
      work_start_date: params[:work_start_date],
      antiquity: params[:antiquity],
      type_contract: params[:type_contract],
      type_working_day: params[:type_working_day],
      regime_type: params[:regime_type],
      employee_number: params[:employee_number],
      departament: params[:departament],
      put: params[:put],
      payment_frequency: params[:payment_frequency],
      banck: params[:banck],
      banck_account: params[:banck_account],
      base_salary: params[:base_salary],
      daily_salary: params[:daily_salary],
      federative_entity_key: params[:federative_entity_key],

      status: 1,

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