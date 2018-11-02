require 'spec_helper'
require 'marketingcloudsdk/version'

describe MarketingCloudSDK::HTTPRequest do
  let(:client) { Class.new.new.extend MarketingCloudSDK::HTTPRequest }
  subject { client }
  it { should respond_to(:get) }
  it { should respond_to(:post) }
  it { should respond_to(:patch) }
  it { should respond_to(:delete) }
  it { should respond_to(:request) }

  describe '#get' do
    it 'makes and Net::HTTP::Get request' do
      client.stub(:request).with(Net::HTTP::Get, 'http://some_url', {}).and_return({'success' => 'get'})
      expect(client.get('http://some_url')).to eq 'success' => 'get'
    end
  end

  describe '#post' do
    describe 'makes and Net::HTTP::Post request' do

      it 'with only url' do
        Net::HTTP.any_instance.stub(:request)
        client.stub(:request).with(Net::HTTP::Post, 'http://some_url', {}).and_return({'success' => 'post'})
        expect(client.post('http://some_url')).to eq 'success' => 'post'
      end

      it 'with params' do
        client.stub(:request)
          .with(Net::HTTP::Post, 'http://some_url', {'params' => {'legacy' => 1}})
          .and_return({'success' => 'post'})
        expect(client.post('http://some_url', {'params' => {'legacy' => 1}})).to eq 'success' => 'post'
      end
    end
  end

  describe '#request' do
    it 'should set Authorization header' do
      params = {'access_token' => 'token'}
      Net::HTTP.any_instance.stub(:request)
      get = double("get")
      get.should_receive(:add_field).with('User-Agent', 'FuelSDK-Ruby-v' + MarketingCloudSDK::VERSION)
      get.should_receive(:add_field).with('Authorization', 'Bearer ' + params['access_token'])
      net = double(Net::HTTP::Get)
      net.stub(:new).with(any_args()).and_return(get)
      client.request(net, 'http://some_url', params)
    end

    it 'should skip setting Authorization header' do
      params = {}
      Net::HTTP.any_instance.stub(:request)
      get = double("get")
      get.should_receive(:add_field).with('User-Agent', 'FuelSDK-Ruby-v' + MarketingCloudSDK::VERSION)
      get.should_not_receive(:add_field).with('Authorization', any_args())
      net = double(Net::HTTP::Get)
      net.stub(:new).with(any_args()).and_return(get)
      client.request(net, 'http://some_url', params)
    end
  end
end
