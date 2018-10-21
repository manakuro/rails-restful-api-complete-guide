require 'rails_helper'

RSpec.describe AccessTokensController, type: :controller do
  describe '#create' do
    shared_examples_for 'unauthorized_requests' do
      let(:error) do
        {
          "status" => "401",
          "source" => { "pointer" => "/code" },
          "title" =>  "Invalid Attribute",
          "detail" => "First name must contain at least three characters."
        }
      end

      it 'should return 401 status code' do
        subject
        expect(response).to have_http_status(401)
      end

      it 'should return proper error body' do
        subject
        expect(json['errors']).to include(error)
      end
    end

    context 'when no code provided' do
      subject { post :create }
      it_behaves_like 'unauthorized_requests'
    end

    context 'when invalid code provided' do
      let(:authenticator_mock) { UserAuthenticator.new('sample_code') }
      let(:github_error) {
        double('Sawyer::Resource', error: 'bad_verification_code')
      }
      let(:client) {
        double('Ocktokit::Client')
      }
      before do
        allow(client).to receive(:exchange_code_for_token).and_return(github_error)
        allow(UserAuthenticator).to receive(:new).and_return(authenticator_mock)
        allow(authenticator_mock).to receive(:client).and_return(client)
      end

      subject { post :create, params: { code: 'invalid' } }
      it_behaves_like 'unauthorized_requests'
    end

    context 'when success request' do
      subject { post :create, params: { code: 'valid' } }
      let(:authenticator_mock) { UserAuthenticator.new('sample_code') }
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
        allow(authenticator_mock).to receive(:client).and_return(client)
        allow(authenticator_mock).to receive(:user_client).and_return(user_client)
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
end
