require 'rails_helper'

RSpec.describe TokensController, type: :controller do
  let(:authorization_error) {
    {
      "status" => "401",
      "source" => { "pointer" => "/code" },
      "title" =>  "Authorization failed",
      "detail" => "The code parameter or authorization header is invalid"
    }
  }

  describe 'POST :create' do
    context 'when invalid request' do
      it 'should have 401 status code if no code provided' do
        expect(post :create).to have_http_status(:unauthorized)
      end

      it 'should contatin valid json api error object' do
        post :create
        expect(json['errors'].length).to eq(1)
        expect(json['errors'].first).to eq(authorization_error)
      end
    end

    context 'when success request' do
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

      subject { post :create, params: { code: 'sample-code' } }

      it 'should have 201 status code' do
        expect(subject)
          .to have_http_status(:created)
      end

      it 'should create user if user does not exist' do
        expect{ subject }
          .to change{ User.count }.by(1)
      end

      it 'should create token if user does not exist' do
        expect{ subject }
          .to change{ Token.count }.by(1)
      end

      it 'should return token in response body' do
        subject
        user = User.find_by(uid: '1')
        token = user.token
        expect(json).to be_present
        expect(json['data']).to include({
          'type' => 'tokens',
          'id' => token.token
        })
      end

      it 'should create token for existing user' do
        user_data = github_data.dup
        user_data[:uid] = user_data.delete(:id)
        user = create :user, user_data
        expect{ subject }.not_to change{ User.count }
        token = json['data']['id']
        expect(Token.find_by(token: token).user).to eq(user)
      end
    end
  end

  describe 'DELETE :destroy' do
    context 'when authorization is not set' do
      it 'should have unauthorized http status' do
        expect(delete :destroy).to have_http_status(:unauthorized)
      end

      it 'should not remove access token' do
        expect{ delete :destroy }.not_to change{ Token.count }
      end

      it 'should return proper error response' do
        delete :destroy
        expect(json['errors'].length).to eq(1)
        expect(json['errors'].first).to eq(authorization_error)
      end
    end

    context 'when authorization is valid' do
      let (:token) { create :token }
      before do
        request.headers['authorization'] = "Bearer #{token.token}"
      end

      it 'should have 203 status code' do
        expect(delete :destroy).to have_http_status(:no_content)
      end

      it 'should destroy the token' do
        expect{ delete :destroy }.to change{ Token.count }.by(-1)
      end
    end
  end
end
