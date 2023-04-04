class EmployeeController < ApplicationController
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
      data = Excel.update_employee(params)
      code = 500
      code = 200 unless data.nil?
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin
      code = 500
      data = nil
      file_excel = params[:fileserexcel]
      array_sheets = []
      xslx = Roo::Spreadsheet.open(file_excel)

      sheets = xslx.sheets
      sheets.each_with_index do |name, index|
        array_sheets[index] = Roo::Spreadsheet.open(file_excel).sheet(name)
      end

      data_excel = Excel.readExcel(array_sheets, params[:slugUser])
      unless data_excel.nil?
        code = 200
        data = data_excel
      end
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def destroy
    begin
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

end