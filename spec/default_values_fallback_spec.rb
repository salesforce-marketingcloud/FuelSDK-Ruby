require 'spec_helper'

describe MarketingCloudSDK::Client do

  context 'Empty string REST endpoint, no Auth attribute' do

    client1 = MarketingCloudSDK::Client.new 'client' => {'id' => '1234', 'secret' => 'ssssh',
                                                        'base_api_url' => ''}

    it 'Should use REST endpoint default value if base_api_url endpoint is an empty string in config' do
      expect(client1.base_api_url).to eq 'https://www.exacttargetapis.com'
    end

    it 'Should use Auth endpoint default value if request_token_url attribute is not in config' do
      expect(client1.request_token_url).to eq 'https://auth.exacttargetapis.com/v1/requestToken'
    end
  end

  context 'Blank string REST endpoint' do

    client2 = MarketingCloudSDK::Client.new 'client' => {'id' => '1234', 'secret' => 'ssssh',
                                                         'base_api_url' => '   '}

    it 'Should use REST endpoint default value if REST endpoint is a blank string in config' do
      expect(client2.base_api_url).to eq 'https://www.exacttargetapis.com'
    end

  end

end
