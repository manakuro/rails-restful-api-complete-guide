class ApplicationController < ActionController::API
  class AuthorizationError < StandardError; end
  rescue_from UserAuthenticator::AuthenticationError,
              with: :authentication_error
  rescue_from AuthorizationError, with: :authorization_error

  before_action :authorize!

  private

  def authorize!
    raise AuthorizationError unless current_user
  end

  def access_token
    provided_token = request.authorization&.gsub(/\ABearer\s/, '')
    @access_token = AccessToken.find_by(token: provided_token)
  end

  def current_user
    @current_user = access_token&.user
  end

  def authentication_error
    error = {
      "status" => "401",
      "source" => { "pointer" => "/code" },
      "title" =>  "Invalid Attribute",
      "detail" => "First name must contain at least three characters."
    }

    render json: { 'errors': [error] }, status: 401
  end
end
