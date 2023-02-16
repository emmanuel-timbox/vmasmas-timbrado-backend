class EmployeController<ApplicationController
  require 'roo'

  def index
  end

  def show
    begin
      result = Employee.get_data_employee(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def update
    begin
      employee = Employee.update_employee(params)
      code = 200
      data = nil
      if employee[:save_data]
        code = 200
        data = show_data(employee[:result])
      end
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end
  def create
    begin
      file_excel = params[:fileserexcel]
      array_sheets = []
      xslx = Roo::Spreadsheet.open(file_excel)
      sheets = xslx.sheets
      sheets.each_with_index do |name, index|
        array_sheets[index] = Roo::Spreadsheet.open(file_excel).sheet(name)
      end
      data_excel = Excel.readExcel(array_sheets, params[:slug])
      render json: {  code: 200 }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  private def show_data(data)
    return {
    rfc: data[:rfc],
      curp: data[:curp],
      social_security_number: data[:social_security_number],
      work_start_date: data[:work_start_date],
      antiquity: data[:antiquity_e],
      type_contract: data[:type_contract],
      unionized: data[:unionized],
      type_working_day: data[:type_working_day],
      regime_type: data[:regime_type],
      employee_number: data[:employee_number],
      departament: data[:departament],
      risk_put: data[:risk_put_e],
      put: data[:put],
      payment_frequency: data[:payment_frequency],
      banck: data[:banck],
      banck_account: data[:banck_account],
      base_salary: data[:base_salary],
      daily_salary: data[:daily_salary],
      federative_entity_key: data[:federative_entity_key],
      slug: data[:slug]
    }
  end

  def destroy
    begin
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end
end