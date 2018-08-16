class TokensController < ApplicationController
skip_before_action :restrict_access, only: :create

  def create
    authenticator = UserAuthenticator.new(params[:code])
    authenticator.perform
    render json: authenticator.access_token, status: :created
  end

  def destroy
    access_token.destroy
  end

  private

end
