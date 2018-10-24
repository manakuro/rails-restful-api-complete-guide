class UserAuthenticator
  class AuthenticationError < StandardError; end

  delegate :client,
           :user_client, :user,
           :perform,
           :access_token, to: :@authenticator, allow_nil: true

  attr_reader :authenticator

  def initialize(code: nil, login: nil, password: nil)
    @authenticator = if code.present?
      Oauth.new(code)
    else
      Standard.new(login, password)
    end
  end
end
