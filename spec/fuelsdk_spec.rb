require 'spec_helper.rb'

describe FuelSDK::ET_Client do

  context 'initialized' do

    it 'defaults to RestClient' do
      client = FuelSDK::ET_Client.new
      expect(client.mode).to eq 'rest'
    end

    it 'with client parameters' do
      client = FuelSDK::ET_Client.new 'client' => { 'id' => '1234', 'secret' => 'ssssh', 'signature' => 'hancock' }
      expect(client.secret).to eq 'ssssh'
      expect(client.id).to eq '1234'
      expect(client.signature).to eq 'hancock'
    end

    it 'with debug=true' do
      client = FuelSDK::ET_Client.new({}, true)
      expect(client.debug).to be_true
    end

    it 'with debug=false' do
      client = FuelSDK::ET_Client.new({}, false)
      expect(client.debug).to be_false
    end

    describe 'with type=soap' do

      let(:client) { FuelSDK::ET_Client.new 'type' => 'soap' }

      it 'creates SoapClient' do
        expect(client).to be_kind_of FuelSDK::Soap
      end

      it '#mode returns soap' do
        expect(client.mode).to eq 'soap'
      end

      it '#wsdl defaults to https://webservice.exacttarget.com/etframework.wsdl' do
        expect(client.wsdl).to eq 'https://webservice.exacttarget.com/etframework.wsdl'
      end
    end

    describe 'with type=rest' do

      let(:client) { FuelSDK::ET_Client.new 'type' => 'rest' }

      it 'creates RestClient' do
        expect(client).to be_kind_of FuelSDK::Rest
      end

      it '#mode returns rest' do
        expect(client.mode).to eq 'rest'
      end
    end

    describe 'with a wsdl' do

      let(:client) { FuelSDK::ET_Client.new 'defaultwsdl' => 'somewsdl' }

      it'creates a SoapClient' do
        expect(client).to be_kind_of FuelSDK::Soap
      end

      it'#wsdl returns default wsdl' do
        expect(client.wsdl).to eq 'somewsdl'
      end
    end
  end

  context 'instance can set' do

    let(:client) { FuelSDK::ET_Client.new }

    it 'client id' do
      client.id = 123
      expect(client.id).to eq 123
    end

    it 'client secret' do
      client.secret = 'sssh'
      expect(client.secret).to eq 'sssh'
    end

    it 'refresh token' do
      client.refresh_token = 'refresh'
      expect(client.refresh_token).to eq 'refresh'
    end

    it 'debug' do
      expect(client.debug).to be_false
      client.debug = true
      expect(client.debug).to be_true
    end
  end

  describe '#jwt=' do

    let(:payload) {
     {
      'request' => {
        'user'=> {
          'oauthToken' => 123456789,
          'expiresIn' => DateTime.new(2001, 01, 01),
          'internalOauthToken' => 987654321,
          'refreshToken' => 101010101010
        }
      }
     }
    }

    let(:sig){
      sig = 'hanckock'
    }

    let(:encoded) {
      JWT.encode(payload, sig)
    }

    it 'raises an exception when signature is missing' do
      expect { FuelSDK::ET_Client.new.jwt = encoded }.to raise_exception 'Require app signature to decode JWT'
    end

    describe 'decodes JWT' do

      let(:sig){
        sig = 'hanckock'
      }

      let(:encoded) {
        JWT.encode(payload, sig)
      }

      let(:client) {
        FuelSDK::ET_Client.new 'client' => { 'id' => '1234', 'secret' => 'ssssh', 'signature' => sig }
      }

      it 'making auth token available to client' do
        client.jwt = encoded
        expect(client.auth_token).to eq 123456789
      end

      it 'making internal token available to client' do
        client.jwt = encoded
        expect(client.internal_token).to eq 987654321
      end

      it 'making refresh token available to client' do
        client.jwt = encoded
        expect(client.refresh_token).to eq 101010101010
      end
    end
  end

  describe '#refresh_token' do
    let(:client) { FuelSDK::ET_Client.new }

    it 'defaults to nil' do
      expect(client.refresh_token).to be_nil
    end

    it 'can be accessed' do
      client.refresh_token = '1234567890'
      expect(client.refresh_token).to eq '1234567890'
    end
  end

  describe '#refresh' do

    let(:client) { FuelSDK::ET_Client.new }

    context 'raises an exception' do

      it 'when client id and secret are missing' do
        expect { client.refresh }.to raise_exception 'Require Client Id and Client Secret to refresh tokens'
      end

      it 'when client id is missing' do
        client.secret = 1234
        expect { client.refresh }.to raise_exception 'Require Client Id and Client Secret to refresh tokens'
      end

      it 'when client secret is missing' do
        client.id = 1234
        expect { client.refresh }.to raise_exception 'Require Client Id and Client Secret to refresh tokens'
      end
    end

    #context 'posts' do
    #  let(:client) { FuelSDK::ET_Client.new 'client' => { 'id' => 123, 'secret' => 'sssh'} }
    #  it 'accessType=offline' do
    #  client.stub(:post)
    #    .with({'clientId' => 123, 'secret' => 'ssh', 'accessType' => 'offline'})
    #    .and_return()
    #end

    #context 'updates' do
    #  let(:client) { FuelSDK::ET_Client.new 'client' => { 'id' => 123, 'secret' => 'sssh'} }

    #  it 'access_token' do
    #    #client.stub(:post).
    #  end
    #end
  end

  describe 'includes HTTPRequest' do

    subject { FuelSDK::ET_Client.new }

    it { should respond_to(:_get_) }
    it { should respond_to(:_post_) }
  end
end
