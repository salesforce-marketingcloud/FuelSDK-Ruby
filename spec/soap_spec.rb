require 'spec_helper'

describe FuelSDK::Soap do

  let(:client) { FuelSDK::Client.new }

  subject { client }

  it { should respond_to(:soap_get) }
  it { should respond_to(:soap_post) }

  it { should respond_to(:header) }
  it { should_not respond_to(:header=) }

  it { should respond_to(:wsdl) }
  it { should respond_to(:wsdl=) }

  it { should respond_to(:endpoint) }
  it { should_not respond_to(:endpoint=) }

  it { should respond_to(:soap_client) }

  its(:debug) { should be_false }
  its(:wsdl) { should eq 'https://webservice.exacttarget.com/etframework.wsdl' }

  describe '#header' do
    it 'raises an exception when internal_token is missing' do
      expect { client.header }.to raise_exception 'Require legacy token for soap header'
    end

    it 'returns header hash' do
      client.internal_token = 'innerspace'
      expect(client.header).to eq(
        {
          'oAuth' => { 'oAuthToken' => 'innerspace' },
          :attributes! => {
            'oAuth' => { 'xmlns' => 'http://exacttarget.com' }
          }
        }
      )
    end

  end
end
