class UserAuthenticator
  class AuthenticationError < StandardError; end

  attr_reader :user, :access_token

  def initialize(code)
    @authentication_code = code
  end

  def perform
    raise AuthenticationError if @authentication_code.blank?
    github_token = client
      .exchange_code_for_token(@authentication_code)
    raise AuthenticationError if github_token.try(:error).present?

    user_data = user_client(github_token).user.to_h.slice(
      :id, :login, :url, :avatar_url, :name)
    user_data[:uid] = user_data.delete(:id)
    prepare_user(user_data)
    @access_token = user.token || user.create_token
  end

  private

  def client
    @client ||= Octokit::Client.new(
      client_id: ENV['GITHUB_ID'],
      client_secret: ENV['GITHUB_SECRET'])
  end

  def user_client(github_token)
    @user_client ||= Octokit::Client.new(
      access_token: github_token)
  end

  def prepare_user(user_data)
    @user = if User.exists?(uid: user_data[:uid], provider: 'github')
      User.find_by(uid: user_data[:uid], provider: 'github')
    else
      User.create!(user_data.merge(provider: 'github'))
    end
  end
end
