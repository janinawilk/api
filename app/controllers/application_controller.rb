class ApplicationController < ActionController::API
  rescue_from UserAuthenticator::AuthenticationError,
    with: :authorization_error

  class AuthorizationError < StandardError; end
  rescue_from AuthorizationError, with: :authorization_error

  before_action :restrict_access

  attr_reader :access_token, :current_user

  protected

  def restrict_access
    raise AuthorizationError unless current_user
  end

  private

  def access_token
    bearer_token = request.authorization&.gsub(/\ABearer /, '')
    @access_token = Token.find_by(token: bearer_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  def authorization_error
    error = {
      "status" => "401",
      "source" => { "pointer" => "/code" },
      "title" =>  "Authorization failed",
      "detail" => "The code parameter or authorization header is invalid"
    }
    render json: { errors: [error] }, status: :unauthorized
  end
end
