class AuthenticateController < ApplicationController

  skip_before_action :authenticate_request, only: [:create]

  def index
  end

  def show
    begin

      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin
      result = User.insert_user(params)
      code = 200
      message = nil
      unless result[:isValid]
        code = 500
        errors = result[:errors]
        repeat = "Ya que #{errors[0]}  ya se encuentran registrado"
        repeat = "Ya que #{errors[0]} y #{errors[1]} ya se encuentran registrados" if errors.count == 2
        message = "No se pudo registrar su informacion en la aplicacion. #{repeat}"
      end
      render json: { code: code, message: message }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def update
    begin

      render json: { code: code, data: data, message: certificate[:message] }
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