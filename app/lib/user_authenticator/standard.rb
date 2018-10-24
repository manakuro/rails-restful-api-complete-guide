class UserAuthenticator::Standard < UserAuthenticator
  class AuthenticationError < StandardError; end

  def initialize(login, password)

  end

  def perform
    raise AuthenticationError
  end

  private

  def client; end

  def user_client; end
end
