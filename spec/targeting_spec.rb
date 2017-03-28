require 'spec_helper'

describe MarketingCloudSDK::Targeting do

  subject { Class.new.new.extend(MarketingCloudSDK::Targeting) }

  it { should respond_to(:endpoint) }
  it { should_not respond_to(:endpoint=) }
  it { should respond_to(:get) }
  it { should respond_to(:post) }
  it { should respond_to(:patch) }
  it { should respond_to(:delete) }
  it { should respond_to(:access_token) }

  describe '#determine_stack' do
    let(:client) { c = Class.new.new.extend(MarketingCloudSDK::Targeting)
      c.stub(:access_token).and_return('open_sesame')
      c.stub(:get)
        .with('https://www.exacttargetapis.com/platform/v1/endpoints/soap',{'params'=>{'access_token'=>'open_sesame'}})
        .and_return({'url' => 'S#.authentication.target'})
      c
    }
    it 'sets @endpoint' do
      expect(client.send(:determine_stack)).to eq 'S#.authentication.target'
    end
  end

  describe '#endpoint' do
    let(:client) { c = Class.new.new.extend(MarketingCloudSDK::Targeting)
      c.stub(:get).and_return({'url' => 'S#.authentication.target'})
      c
    }

    it 'calls determine_stack to find target' do
      expect(client.endpoint).to eq 'S#.authentication.target'
    end
  end
end
