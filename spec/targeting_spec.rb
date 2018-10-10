require 'spec_helper'

describe MarketingCloudSDK::Targeting do

  subject { Class.new.new.extend(MarketingCloudSDK::Targeting) }

  it { should respond_to(:endpoint) }
  it { should_not respond_to(:endpoint=) }
  it { should_not respond_to(:get_soap_endpoint) }
  it { should respond_to(:get) }
  it { should respond_to(:post) }
  it { should respond_to(:patch) }
  it { should respond_to(:delete) }
  it { should respond_to(:access_token) }

  describe '#get_soap_endpoint' do
    let(:client) { c = Class.new.new.extend(MarketingCloudSDK::Targeting)
      c.stub(:base_api_url).and_return('https://www.exacttargetapis.com')
      c.stub(:access_token).and_return('open_sesame')
      c.stub(:get_soap_endpoint_from_file).and_return(nil)
      c.stub(:set_soap_endpoint_to_file).and_return(nil)
      c.stub(:get)
        .with('https://www.exacttargetapis.com/platform/v1/endpoints/soap',{'access_token'=>'open_sesame'})
        .and_return({'url' => 'S#.authentication.target'})
      c
    }
    it 'sets @endpoint' do
      client.send(:get_soap_endpoint)
      expect(client.endpoint).to eq 'S#.authentication.target'
    end
  end

  describe '#endpoint' do
    let(:client) { c = Class.new.new.extend(MarketingCloudSDK::Targeting)
      c.stub(:base_api_url).and_return('bogus url')
      c.stub(:get).and_return({'url' => 'S#.authentication.target'})
      c
    }

    it 'calls get_soap_endpoint to find target' do
      expect(client.endpoint).to eq 'S#.authentication.target'
    end
  end
end
