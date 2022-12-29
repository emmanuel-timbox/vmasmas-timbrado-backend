class TaxDataConfigsController < ApplicationController

  def index
  end

  def show
    begin
      result = Emitter.get_data_emmiter(params[:id])
      code = result.nil? ? 500 : 200
      render json: {code: code, data: result}
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin
      data = Emitter.insert_people_tax(params)
      code = data.nil? ? 500 : 200
      unless data.nil?
        data = show_data(data)
      end
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def update

  end

  def destroy
    begin
      code = 500
      data = nil
      emitter = Emitter.update_status_emitter(params[:id])
      if emitter[:save]
        data = show_data(emitter[:result])
        code = 200
      end
      render json: {  code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  private def show_data(data)
    return {
      rfc: data[:rfc],
      bussiness_name: data[:bussiness_name],
      tax_regime: data[:tax_regime],
      expedition_place: data[:expedition_place],
      status: data[:status],
      slug: data[:slug]
    }
  end

end
