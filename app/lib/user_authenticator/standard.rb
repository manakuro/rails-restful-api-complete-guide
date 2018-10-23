class UserAuthenticator::Standard < UserAuthenticator
  class AuthenticationError < StandardError; end

  def initialize(login: nil, password: nil)

  end

  def perform
    raise AuthenticationError
  end

  private

  def client
    {}
  end
end
