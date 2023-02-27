class ApplicationController < ActionController::Base

  include JsonWebToken
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decode = jwt_decode(header)
    @current_user = User.find_by(slug: decode[:slug])
  end

end
