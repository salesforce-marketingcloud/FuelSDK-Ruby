require 'spec_helper.rb'
require 'public_or_web_integration_credentials'

def get_test_stub
  {'client' => {
      'use_oAuth2_authentication' => true,
      'id' => 'id',
      'secret' => 'secret',
      'request_token_url' => 'request_token_url',
      'account_id' => 'account_id',
      'authorization_code' => 'authorization_code',
      'redirect_URI' => 'redirect_URI'
  }}
end

describe(MarketingCloudSDK::Client) do

  context 'initialized' do

    before(:each) do
      allow_any_instance_of(MarketingCloudSDK::Client).to receive(:refresh).and_return(true)
    end

    it 'with client parameters' do
      test_stub = get_test_stub

      client = MarketingCloudSDK::Client.new(test_stub)

      expect(client.use_oAuth2_authentication).to be test_stub['client']['use_oAuth2_authentication']
      expect(client.id).to eq test_stub['client']['id']
      expect(client.secret).to eq test_stub['client']['secret']
      expect(client.account_id).to eq test_stub['client']['account_id']
      expect(client.request_token_url).to eq test_stub['client']['request_token_url']
    end

    it 'with debug=true' do
      client = MarketingCloudSDK::Client.new(get_test_stub, true)

      expect(client.debug).to be true
    end

    it 'with debug=false' do
      client = MarketingCloudSDK::Client.new(get_test_stub, false)

      expect(client.debug).to be false
    end

    it 'with base_api_url set to default value if base_api_url is not set' do
      client = MarketingCloudSDK::Client.new(get_test_stub)

      expect(client.base_api_url).to eq 'https://www.exacttargetapis.com'
    end

    it 'with null/blank/empty request_token_url and use_oAuth2_authentication=true should raise exception' do
      expected_exception = 'request_token_url (Auth TSE) is mandatory when using OAuth2 authentication'

      test_stub = get_test_stub

      [nil, '   ', ''].each do |exception_raiser|
        test_stub['client']['request_token_url'] = exception_raiser
        expect { MarketingCloudSDK::Client.new(test_stub) }.to raise_error(expected_exception)
      end
    end

    it 'with SoapClient' do
      client = MarketingCloudSDK::Client.new(get_test_stub)

      expect(client).to be_kind_of MarketingCloudSDK::Soap
    end

    it 'with RestClient' do
      client = MarketingCloudSDK::Client.new(get_test_stub)

      expect(client).to be_kind_of MarketingCloudSDK::Rest
    end

    it 'with wsdl set to default value if  not set in params' do
      client = MarketingCloudSDK::Client.new(get_test_stub)

      expect(client.wsdl).to eq 'https://webservice.exacttarget.com/etframework.wsdl'
    end

    it 'with application_type set to \'server\' if application_type is not set in params' do
      client = MarketingCloudSDK::Client.new(get_test_stub)

      expect(client.application_type).to eq 'server'
    end

    describe 'with web/public app and null/blank/empty authorization_code or redirect_URI should raise exception' do
      expected_exception = 'authorization_code or redirect_URI is null: For Public/Web Apps, the authorization_code and redirect_URI must be passed when instantiating Client'

      exception_raisers = Hash.new.tap do |h|
        h[nil] = 'nil'
        h['   '] = 'blank string'
        h[''] = 'empty string'
      end

      test_stub = get_test_stub

      ['web', 'public'].each do |app_type|
        [nil, '   ', ''].each do |exception_raiser|
          ['authorization_code', 'redirect_URI'].each do |under_test_prop|

            it "#{app_type} app with #{exception_raisers[exception_raiser]} #{under_test_prop} raises an exception" do

              test_stub['client']['application_type'] = app_type
              test_stub['client'][under_test_prop] = exception_raiser

              expect { MarketingCloudSDK::Client.new(test_stub) }.to raise_error(expected_exception)
            end
          end
        end
      end
    end

    it 'with public app and null/blank/empty id should raise exception' do
      expected_exception = 'id is null: id must be passed when instantiating Client'

      test_stub = get_test_stub
      test_stub['client']['application_type'] = 'public'
      test_stub['client']['authorization_code'] = 'authorization_code'
      test_stub['client']['redirect_URI'] = 'redirect_URI'

      [nil, '   ', ''].each do |exception_raiser|
        test_stub['client']['id'] = exception_raiser

        expect { MarketingCloudSDK::Client.new(test_stub) }.to raise_error(expected_exception)
      end
    end

    describe 'with web/server app and null/blank/empty id or secret should raise exception' do
      expected_exception = 'id and secret must pe passed when instantiating Client'

      exception_raisers = Hash.new.tap do |h|
        h[nil] = 'nil'
        h['   '] = 'blank string'
        h[''] = 'empty string'
      end

      test_stub = get_test_stub
      test_stub['client']['authorization_code'] = 'authorization_code'
      test_stub['client']['redirect_URI'] = 'redirect_URI'

      ['web', 'server'].each do |app_type|
        [nil, '   ', ''].each do |exception_raiser|
          ['id', 'secret'].each do |under_test_prop|

            it "#{app_type} app with #{exception_raisers[exception_raiser]} #{under_test_prop} raises an exception" do

            test_stub['client']['application_type'] = app_type
            test_stub['client'][under_test_prop] = exception_raiser

            expect { MarketingCloudSDK::Client.new(test_stub) }.to raise_error(expected_exception)
            end
          end
        end
      end
    end

    describe 'with a wsdl' do

      test_stub = get_test_stub

      let(:client) { MarketingCloudSDK::Client.new test_stub }

      it'creates a SoapClient' do
        expect(client).to be_kind_of MarketingCloudSDK::Soap
      end

      it'#wsdl returns default wsdl' do
        expect(client.wsdl).to eq 'https://webservice.exacttarget.com/etframework.wsdl'
      end
    end
  end

  context 'instance can set' do

    before(:each) do
      allow_any_instance_of(MarketingCloudSDK::Client).to receive(:refresh).and_return(true)
    end

    let(:client) { MarketingCloudSDK::Client.new (get_test_stub)}

    it 'client id' do
      client.id = 'some_id'

      expect(client.id).to eq 'some_id'
    end

    it 'client secret' do
      client.secret = 'some_secret'

      expect(client.secret).to eq 'some_secret'
    end

    it 'refresh token' do
      client.refresh_token = 'some_refresh_token'

      expect(client.refresh_token).to eq 'some_refresh_token'
    end

    it 'debug' do
      client.debug = false
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
                  'oauthToken' => 'oAuthToken',
                  'expiresIn' => 3600,
                  'internalOauthToken' => 'internalOauthToken',
                  'refreshToken' => 'refreshToken'
              },
              'application'=> {
                  'package' => 'JustTesting'
              }
          }
      }
    }

    let(:sig){
      sig = 'signature'
    }

    let(:encoded) {
      JWT.encode(payload, sig)
    }

    it 'raises an exception when signature is missing' do
      test_stub = get_test_stub
      test_stub['jwt'] = encoded

      expect { MarketingCloudSDK::Client.new test_stub }.to raise_exception 'Require app signature to decode JWT'
    end

    describe 'decodes JWT' do

      before(:each) do
        allow_any_instance_of(MarketingCloudSDK::Client).to receive(:refresh).and_return(true)
      end

      let(:sig){
        sig = 'signature'
      }

      let(:encoded) {
        JWT.encode(payload, sig)
      }

      let(:client) {
        test_stub = get_test_stub
        test_stub['client']['signature'] = sig
        test_stub['jwt'] = encoded

        MarketingCloudSDK::Client.new test_stub
      }

      it 'making auth token available to client' do
        expect(client.auth_token).to eq payload['request']['user']['oauthToken']
      end

      it 'making internal token available to client' do
        expect(client.internal_token).to eq payload['request']['user']['internalOauthToken']
      end

      it 'making refresh token available to client' do
        expect(client.refresh_token).to eq payload['request']['user']['refreshToken']
      end
    end
  end

  describe '#refresh_token' do

    before(:each) do
      allow_any_instance_of(MarketingCloudSDK::Client).to receive(:refresh).and_return(true)
    end

    let(:client) { MarketingCloudSDK::Client.new get_test_stub }

    it 'defaults to nil' do
      expect(client.refresh_token).to be_nil
    end

    it 'can be accessed' do
      client.refresh_token = 'refresh_token'
      expect(client.refresh_token).to eq 'refresh_token'
    end
  end

  context 'authentication payload' do

    before(:each) do
      allow_any_instance_of(MarketingCloudSDK::Client).to receive(:refresh).and_return(true)
    end

    it 'should have public app attributes' do
      test_stub = get_test_stub
      test_stub['client']['application_type'] = 'public'

      client = MarketingCloudSDK::Client.new(test_stub)

      payload = client.createPayload

      expect(client.id).to eq payload['client_id']
      expect(client.redirect_URI).to eq payload['redirect_uri']
      expect(client.authorization_code).to eq payload['code']
      expect('authorization_code').to eq payload['grant_type']
    end

    it 'should not have client secret for public app' do
      test_stub = get_test_stub
      test_stub['client']['application_type'] = 'public'

      client = MarketingCloudSDK::Client.new(test_stub)

      payload = client.createPayload

      expect(payload.key?('client_secret')).to be false
    end

    it 'should have web app attributes' do
      test_stub = get_test_stub
      test_stub['client']['application_type'] = 'web'

      client = MarketingCloudSDK::Client.new(test_stub)

      payload = client.createPayload

      expect('authorization_code').to eq payload['grant_type']
      expect(client.id).to eq payload['client_id']
      expect(client.secret).to eq payload['client_secret']
      expect(client.redirect_URI).to eq payload['redirect_uri']
      expect(client.authorization_code).to eq payload['code']
    end

    it 'should have server attributes' do
      test_stub = get_test_stub
      test_stub['client']['application_type'] = 'server'

      client = MarketingCloudSDK::Client.new(test_stub)

      payload = client.createPayload

      expect('client_credentials').to eq payload['grant_type']
      expect(client.id).to eq payload['client_id']
      expect(client.secret).to eq payload['client_secret']
    end

    it 'should not have code and redirect_uri for server app' do
      test_stub = get_test_stub
      test_stub['client']['application_type'] = 'server'

      client = MarketingCloudSDK::Client.new(test_stub)

      payload = client.createPayload

      expect(payload.key?('code')).to be false
      expect(payload.key?('redirect_uri')).to be false
    end

    it 'should have refresh_token attribute when refresh_token is not null/blank/empty on client' do
      test_stub = get_test_stub
      test_stub['refresh_token'] = 'refresh_token'
      test_stub['client']['application_type'] = 'public'

      client = MarketingCloudSDK::Client.new(test_stub)

      payload = client.createPayload

      expect('refresh_token').to eq payload['grant_type']
      expect(client.refresh_token).to eq payload['refresh_token']
    end
  end

  context 'for public and web integrations, access_token and refresh_token' do
  # Test expects a Public/Web App integration config in spec/public_or_web_integration_credentials.rb
    it 'should differ if refresh token is enforced' do

      client = MarketingCloudSDK::Client.new(auth)

      auth_token1 = client.access_token
      refresh_token1 = client.refresh_token

      client.refreshWithOAuth2(true)

      auth_token2 = client.access_token
      refresh_token2 = client.refresh_token

      expect(auth_token1).not_to eq(auth_token2)
      expect(refresh_token1).not_to eq(refresh_token2)
    end
  end

  describe 'includes HTTPRequest' do

    before(:each) do
      allow_any_instance_of(MarketingCloudSDK::Client).to receive(:refresh).and_return(true)
    end

    subject { MarketingCloudSDK::Client.new get_test_stub}

    it { should respond_to(:get) }
    it { should respond_to(:post) }
    it { should respond_to(:patch) }
    it { should respond_to(:delete) }

  end
end
