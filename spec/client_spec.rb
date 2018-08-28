require 'spec_helper.rb'

describe MarketingCloudSDK::Client do

  context 'initialized' do

    it 'with client parameters' do
      client = MarketingCloudSDK::Client.new 'client' => {'id' => '1234', 'secret' => 'ssssh', 'signature' => 'hancock',
                                                          'base_api_url' => 'http://getapis', 'request_token_url' => 'http://authapi'}
      expect(client.secret).to eq 'ssssh'
      expect(client.id).to eq '1234'
      expect(client.signature).to eq 'hancock'
      expect(client.base_api_url).to eq 'http://getapis'
      expect(client.request_token_url).to eq 'http://authapi'
    end

    it 'with debug=true' do
      client = MarketingCloudSDK::Client.new({}, true)
      expect(client.debug).to be true
    end

    it 'with debug=false' do
      client = MarketingCloudSDK::Client.new({}, false)
      expect(client.debug).to be false
    end

    it 'sets the request_token url to parameter if it exists' do
      client = MarketingCloudSDK::Client.new({'request_token_url' => 'fake/url'}, false)
      expect(client.request_token_url).to eq 'fake/url'
    end

    it 'sets the base_api_url url to a default if it does not exist' do
      client = MarketingCloudSDK::Client.new({}, false)
      expect(client.base_api_url).to eq 'https://www.exacttargetapis.com'
    end

    it 'sets the request_token url to a default if it does not exist' do
      client = MarketingCloudSDK::Client.new({}, false)
      expect(client.request_token_url).to eq 'https://auth.exacttargetapis.com/v1/requestToken'
    end

    it 'creates SoapClient' do
      client = MarketingCloudSDK::Client.new
      expect(client).to be_kind_of MarketingCloudSDK::Soap
    end

    it '#wsdl defaults to https://webservice.exacttarget.com/etframework.wsdl' do
      client = MarketingCloudSDK::Client.new
      expect(client.wsdl).to eq 'https://webservice.exacttarget.com/etframework.wsdl'
    end

    it 'creates RestClient' do
      client = MarketingCloudSDK::Client.new
      expect(client).to be_kind_of MarketingCloudSDK::Rest
    end

    describe 'with a wsdl' do

      let(:client) { MarketingCloudSDK::Client.new 'defaultwsdl' => 'somewsdl' }

      it'creates a SoapClient' do
        expect(client).to be_kind_of MarketingCloudSDK::Soap
      end

      it'#wsdl returns default wsdl' do
        expect(client.wsdl).to eq 'somewsdl'
      end
    end
  end

  context 'instance can set' do

    let(:client) { MarketingCloudSDK::Client.new }

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
      expect(client.debug).to be false
      client.debug = true
      expect(client.debug).to be true
    end
  end

  describe '#jwt=' do

    let(:payload) {
     {
      'request' => {
        'user'=> {
          'oauthToken' => 123456789,
          'expiresIn' => 3600,
          'internalOauthToken' => 987654321,
          'refreshToken' => 101010101010
        },
        'application'=> {
          'package' => 'JustTesting'
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
      expect { MarketingCloudSDK::Client.new.jwt = encoded }.to raise_exception 'Require app signature to decode JWT'
    end

    describe 'decodes JWT' do

      let(:sig){
        sig = 'hanckock'
      }

      let(:encoded) {
        JWT.encode(payload, sig)
      }

      let(:client) {
        MarketingCloudSDK::Client.new 'client' => { 'id' => '1234', 'secret' => 'ssssh', 'signature' => sig }
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
    let(:client) { MarketingCloudSDK::Client.new }

    it 'defaults to nil' do
      expect(client.refresh_token).to be_nil
    end

    it 'can be accessed' do
      client.refresh_token = '1234567890'
      expect(client.refresh_token).to eq '1234567890'
    end
  end

  describe '#refresh' do

    let(:client) { MarketingCloudSDK::Client.new }

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
    #  let(:client) { MarketingCloudSDK::Client.new 'client' => { 'id' => 123, 'secret' => 'sssh'} }
    #  it 'accessType=offline' do
    #  client.stub(:post)
    #    .with({'clientId' => 123, 'secret' => 'ssh', 'accessType' => 'offline'})
    #    .and_return()
    #end

    #context 'updates' do
    #  let(:client) { MarketingCloudSDK::Client.new 'client' => { 'id' => 123, 'secret' => 'sssh'} }

    #  it 'access_token' do
    #    #client.stub(:post).
    #  end
    #end
  end

  describe 'includes HTTPRequest' do

    subject { MarketingCloudSDK::Client.new }

    it { should respond_to(:get) }
    it { should respond_to(:post) }
    it { should respond_to(:patch) }
    it { should respond_to(:delete) }
  end
end
