require 'rails_helper'

describe UserAuthenticator::Oauth do
  describe '#perform' do
    let(:authenticator) { described_class.new(code: 'sample_code') }
    subject { authenticator.perform }
    context 'when code is incorrect' do
      let(:error) {
        double('Sawyer::Resource', error: 'bad_verification_code')
      }
      let(:client) {
        double('Ocktokit::Client')
      }
      before do
        allow(client).to receive(:exchange_code_for_token).and_return(error)
        allow(authenticator).to receive(:client).and_return(client)
      end

      it 'should raise an error' do
        expect{ subject }.to raise_error(
                               UserAuthenticator::Oauth::AuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
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
        allow(user_client).to receive(:user).and_return(user_data)
        allow(authenticator).to receive(:client).and_return(client)
        allow(authenticator).to receive(:user_client).and_return(user_client)
      end

      it 'should save the user when does not exists' do
        expect{ subject }.to change{ User.count }.by(1)
        expect(User.last.name).to eq('name')
      end

      it 'should reuse already registered user' do
        user = create :user, user_data
        expect{ subject }.not_to change{ User.count }
        expect(authenticator.user).to eq(user)
      end

      it 'should create and set user\'s access token' do
        expect{ subject }.to change{ AccessToken.count }.by(1)
        expect(authenticator.access_token).to be_present
      end
    end
  end

end
