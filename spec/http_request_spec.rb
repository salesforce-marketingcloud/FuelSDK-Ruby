require 'spec_helper'

describe FuelSDK::HTTPRequest do
  let(:client) { Class.new.new.extend FuelSDK::HTTPRequest }
  subject { client }
  it { should respond_to(:_get_) }
  it { should respond_to(:_post_) }
  it { should_not respond_to(:request) } # private method

  describe '#_get_' do
    it 'makes and Net::HTTP::Get request' do
      client.stub(:request).with(Net::HTTP::Get, 'http://some_url', {}).and_return({'success' => 'get'})
      expect(client._get_('http://some_url')).to eq 'success' => 'get'
    end
  end

  describe '#_post_' do
    describe 'makes and Net::HTTP::Post request' do

      it 'with only url' do
        Net::HTTP.any_instance.stub(:request)
        client.stub(:request).with(Net::HTTP::Post, 'http://some_url', {}).and_return({'success' => 'post'})
        expect(client._post_('http://some_url')).to eq 'success' => 'post'
      end

      it 'with params' do
        client.stub(:request)
          .with(Net::HTTP::Post, 'http://some_url', {'params' => {'legacy' => 1}})
          .and_return({'success' => 'post'})
        expect(client._post_('http://some_url', {'params' => {'legacy' => 1}})).to eq 'success' => 'post'
      end
    end
  end
end
