class TaxConfigsController < ApplicationController
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