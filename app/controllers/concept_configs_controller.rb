class ConceptConfigsController < ApplicationController

  def index
  end

  def show
    begin
      result = Concept.get_data_concept(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin

      data = Concept.insert_concept(params)
      code = data.nil? ? 500 : 200
      unless data.nil?
        data = show_data(data)
      end
      byebug
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def update
    begin
      concept = Concept.update_concept(params)
      code = 500
      data = nil
      if concept[:save_data]
        code = 200
        data = show_data(concept[:result])
      end
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def destroy
    begin
      code = 500
      data = nil
      concept = Concept.update_status_concept(params[:id])
      if concept[:save]
        data = show_data(concept[:result])
        code = 200
      end
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  private def show_data(data)
    return {
      product_key: data[:product_key],
      id_number: data[:id_number],
      unit_key: data[:unit_key],
      unit: data[:unit],
      description: data[:description],
      tax_object: data[:tax_object],
      status: data[:status],
      slug: data[:slug]
    }
  end

end