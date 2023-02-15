class CreateXmlController < ApplicationController

  def index
  end

  def show
    begin
      result = Emitter.get_data_emmiter_xml(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin
      byebug
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

  def show_receivers
    begin
      result = Receiver.get_data_receiver(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def show_concepts
    begin
      result = Concept.get_data_concept(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { code: 500, message: e.message }
    end
  end

  def show_taxes
    begin
      result = Tax.get_data_taxes(params[:id])
      code = result.nil? ? 500 : 200
      render json: { code: code, data: result }
    rescue Exception => e
      render json: { code: 500, message: e.message }
    end
  end

  def validate_key
    begin
      certificate = Certificate.get_certificate(params[:id])
      validateKey = ValidateKey.new(params[:password], params[:key_file],
                                    certificate[:certificate_pem])
      validate = validateKey.check_key
      code = validate[:is_valid] ? 200 : 500
      render json: { code: code, message: validate[:message] }
    rescue Exception => e
      render json: { code: 500, message: e.message }
    end
  end

end