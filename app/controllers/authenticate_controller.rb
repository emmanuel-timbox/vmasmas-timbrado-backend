class AuthenticateController < ApplicationController

  require 'json_web_token'
  skip_before_action :authenticate_request, only: [:create, :login]

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

  def login
    begin
      @user = User.find_by_email(params[:email])
      if @user&.authenticate(params[:password])
        token = JsonWebToken.jwt_encode(slug: @user.slug)
        user = {
          email: @user.email,
          name: @user.name,
          slug: @user.slug
        }
        render json: {code: 200, token: token, data: user}
      else
        render json: { code: 500, token: nil}
      end
    rescue Exception => e
      render json: {code: 500, message:e.message}
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