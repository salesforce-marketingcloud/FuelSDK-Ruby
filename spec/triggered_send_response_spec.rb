require 'spec_helper.rb'

describe FuelSDK::TriggeredSendResponse do

  let(:client) { double('FuelSDK::Client') }
  let(:raw) { 'FIXME' }
  subject { described_class.new(raw, client) }

  context '#success?' do
    it 'returns false if the SOAP request was not successful' do
      fail('Not implemented')
    end

    it 'returns false if the TriggeredSend was not created' do
      fail('Not implemented')
    end

    it 'returns true if the SOAP request was not successful and TriggeredSend was created' do
      fail('Not implemented')
    end
  end

  context '#success' do
    it 'is an alias of success?' do
      expect(subject.method(:success)).to eq(subject.method(:success?))
    end
  end

  context '#some other method (needs to quack)' do
    it 'delegates to the FuelSDK::Response' do
      fail('Not implemented')
    end
  end
end