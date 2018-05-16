require 'spec_helper.rb'

describe FuelSDK::TriggeredSendResponse do

  let(:raw_response) { double('FuelSDK::Response') }
  subject { described_class.new(raw_response) }

  context '#success?' do
    it 'returns false if the SOAP request was not successful' do
      expect(raw_response).to receive(:success).and_return(false)
      expect(subject.success).to be false
    end

    it 'returns false if the TriggeredSend was not created' do
      expect(raw_response).to receive(:success).and_return(true)
      expect(subject.success).to be false
    end

    it 'returns true if the SOAP request was not successful and TriggeredSend was created' do
      expect(raw_response).to receive(:success).and_return(true)
      expect(subject.success).to be true
    end
  end

  context '#success' do
    it 'has an alias of success?' do
      expect(subject.method(:success)).to eq(subject.method(:success?))
    end

    it 'has an alias of status' do
      expect(subject.method(:success)).to eq(subject.method(:success?))
    end
  end

  context '#some other method (needs to quack)' do
    it 'delegates to the FuelSDK::Response' do
      fail('Not implemented')
    end
  end
end