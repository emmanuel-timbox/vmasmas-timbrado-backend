class TaxConfigsController < ApplicationController
  def index
  end

  def show
    begin
      result = Tax.get_data_taxes(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin
      # hay que realizar la validacion que no se encuentre registrado el mismo
      # impuesto con el mismo valor.
      code = 500
      result = Tax.insert_tax(params)
      unless result[:data].nil?
        code = 200
        data = data_formatter(result[:data])
      end
      render json: { code: code, data: data, message: result[:message] }
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
      code = 500
      data = nil
      tax = Tax.update_tax_status(params[:id])
      unless tax.nil?
        code = 200
        data = data_formatter(tax)
      end
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  private def data_formatter(data)
    return {
      tax_key: data[:tax_key],
      tax_name: data[:tax_name],
      tax_rate: data[:tax_rate],
      status: data[:status],
      slug: data[:slug]
    }
  end

end