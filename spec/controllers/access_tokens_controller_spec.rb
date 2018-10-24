require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe 'POST #create' do
    context 'when no auth_data provided' do
      subject { post :create }
      it_behaves_like 'unauthorized_standard_requests'
    end

    context 'when invalid code provided' do
      let(:authenticator_mock) { UserAuthenticator.new }
      let(:github_error) {
        double('Sawyer::Resource', error: 'bad_verification_code')
      }
      let(:client) {
        double('Ocktokit::Client')
      }
      before do
        allow(client).to receive(:exchange_code_for_token).and_return(github_error)
        allow(UserAuthenticator).to receive(:new).and_return(authenticator_mock)
        allow(authenticator_mock.authenticator).to receive(:client).and_return(client)
      end

      subject { post :create, params: { code: 'invalid' } }
      it_behaves_like 'unauthorized_standard_requests'
    end

    context 'when success request' do
      subject { post :create, params: { code: 'valid' } }
      let(:authenticator_mock) { UserAuthenticator.new(code: 'valid') }
      let(:user_client) {
        double('Ocktokit::Client')
      }
      let(:client) {
        double('Ocktokit::Client')
      }
      let(:user_data) do
        {
          login: 'login',
          avatar_url: 'avatar_url',
          url: 'url',
          name: 'name'
        }
      end
      before do
        allow(client).to receive(:exchange_code_for_token).and_return('valid')
        allow(UserAuthenticator).to receive(:new).and_return(authenticator_mock)
        allow(user_client).to receive(:user).and_return(user_data)
        allow(authenticator_mock.authenticator).to receive(:client).and_return(client)
        allow(authenticator_mock.authenticator).to receive(:user_client).and_return(user_client)
      end

      it 'should return 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should return propery json body' do
        expect{ subject }.to change{ User.count }.by(1)
        user = User.find_by(login: 'login')
        expect(json_data['attributes']).to eq(
          { 'token' => user.access_token.token }
        )
      end
    end
  end


  describe 'DELETE #destroy' do
    subject { delete :destroy }

    context 'when not authorization header provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid authorization header provided' do
      before do
        request.headers['authorization'] = 'Invalid token'
      end
      it_behaves_like 'forbidden_requests'
    end

    context 'when valid request' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }

      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it 'should return 204 status code' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'should remove the proper access token' do
        expect{ subject }.to change{ AccessToken.count }.by(-1)
      end
    end
  end
end
