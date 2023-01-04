class ReceiverConfigsController < ApplicationController

    def index
    end
  
    def show
      begin
        result = Receiver.get_data_receiver(params[:id])
        code = result.nil? ? 500 : 200
        render json: { code: code, data: result }
        rescue Exception => e
        render json: { message: e.message, code: 500 }
      end
    end
  
    def create
      begin
        data = Receiver.insert_receiver(params)
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
      begin
        receiver = Receiver.update_receiver(params)
        code = 500
        data = nil
        if receiver[:save_data]
          code = 200
          data = show_data(receiver[:result])
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
        receiver = Receiver.update_status_receiver(params[:id])
        if receiver[:save]
          data = show_data(receiver[:result])
          code = 200
        end
        render json: { code: code, data: data }
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