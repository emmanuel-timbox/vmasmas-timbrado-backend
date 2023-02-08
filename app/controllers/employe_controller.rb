class EmployeController<ApplicationController
  require 'roo'

  def index
  end

  def show
    begin

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
      byebug
      data_excel = Excel.readExcel(array_sheets)
      render json: {  code: 200 }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def update
    begin
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