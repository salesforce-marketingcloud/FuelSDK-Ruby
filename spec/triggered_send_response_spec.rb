require 'spec_helper.rb'

describe FuelSDK::TriggeredSendResponse do

  def build_raw(message)
    data = { :envelope => { :body => { :create_response => { :results => { :status_message => message } } } } }
    double('raw', hash: data)
  end

  def build_empty_raw
    data = { :envelope => { :body => {} }}
    double('raw', hash: data)
  end

  let(:inner_response) { double('FuelSDK::Response') }
  subject { described_class.new(inner_response) }

  context '#success' do
    it 'returns false if the SOAP request was not successful' do
      expect(inner_response).to receive(:success).and_return(false)
      expect(subject.success).to be false
    end

    it 'returns false if the SOAP request was successful but the raw response did not include a CreateResponse' do
      raw = build_empty_raw
      expect(inner_response).to receive(:raw).and_return(raw)
      expect(inner_response).to receive(:success).and_return(true)
      expect(subject.success).to be false
    end

    it 'returns false if the SOAP request was successful but the TriggeredSend was not created' do
      raw = build_raw 'Incorrect Status Message'
      expect(inner_response).to receive(:raw).and_return(raw)
      expect(inner_response).to receive(:success).and_return(true)
      expect(subject.success).to be false
    end

    it 'returns true if the SOAP request was successful and TriggeredSend was created' do
      raw = build_raw 'Created TriggeredSend'
      expect(inner_response).to receive(:raw).and_return(raw)
      expect(inner_response).to receive(:success).and_return(true)
      expect(subject.success).to be true
    end

    it 'has an alias of success?' do
      expect(subject.method(:success)).to eq(subject.method(:success?))
    end

    it 'has an alias of status' do
      expect(subject.method(:success)).to eq(subject.method(:success?))
    end
  end

  context 'is a delegator' do
    it 'delegates to the FuelSDK::Response' do
      expect(subject.__getobj__).to eq inner_response
    end
  end
end
