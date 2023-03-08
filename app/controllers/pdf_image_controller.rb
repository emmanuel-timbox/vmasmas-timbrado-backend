class PdfImageController < ApplicationController
  def index
  end

  def show
    begin
      data = PdfImage.get_images(params[:id])
      code = data.nil? ? 500 : 200
      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def create
    begin
      code = 500
      data = nil
      pdf_image = PdfImage.insert_images(params)
      unless pdf_image.nil?
        code = 200
        data = formatter_data(pdf_image)
      end
      render json: { code: code, data: data}
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def update
    begin
      code = PdfImage.update_images(params) ? 200 : 500
      render json: { code: code, data: nil }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  def destroy
    begin

      render json: { code: code, data: data }
    rescue Exception => e
      render json: { message: e.message, code: 500 }
    end
  end

  private

  def formatter_data(data)
    return {
      logo_image_url: data[:logo_image_url],
      water_mark_image_url: data[:water_mark_image_url],
      slug: data[:slug]
    }
  end

end