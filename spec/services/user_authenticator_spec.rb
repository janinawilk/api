require 'rails_helper'

describe UserAuthenticator do
  describe '.perform' do
    let(:authenticator) { described_class.new('sample_code') }

    context 'when code is incorrect' do
      let(:error) {
        double(
          'Sawyer::Resource',
          :error=>"bad_verification_code",
          :error_description=>"The code passed is incorrect or expired.",
          :error_uri=>
          "https://developer.github.com/apps/managing-oauth-apps/troubleshooting-oauth-app-access-token-request-errors/#bad-verification-code"
        )
      }

      before do
        allow_any_instance_of(Octokit::Client)
        .to receive(:exchange_code_for_token)
        .and_return(error)
      end

      it 'should not save the user ' do
        expect{ authenticator.perform }
          .to raise_error(UserAuthenticator::AuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
      let(:github_data) {
        {
          login: 'jsmith',
          id: '1',
          url: 'https://github.com/jsmith',
          avatar_url: 'https://github.com/avatars/jsmith.jpg',
          name: 'John Smith'
        }
      }

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token).and_return('access-token')
        allow_any_instance_of(Octokit::Client).to receive(
          :user).and_return(github_data)
      end

      it 'should save the user if does not exist' do
        expect{ authenticator.perform }
          .to change{ User.count }.by(1)
        expect(authenticator.user.name).to eq(github_data[:name])
      end

      it 'should find user by github id if exists' do
        user_data = github_data.dup
        user_data[:uid] = user_data.delete(:id)
        user = create :user, user_data
        expect{ authenticator.perform }
          .not_to change{ User.count }
        expect(authenticator.user).to eq(user)
      end

      it 'should create and set user access token' do
        expect{ authenticator.perform }.to change{ Token.count }.
          by(1)
        expect(authenticator.access_token).to be_present        
      end
    end
  end
end
