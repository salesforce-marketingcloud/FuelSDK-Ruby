require 'spec_helper.rb'

describe FuelSDK::TriggeredSendResponse do

  def build_raw(message)
    data = { :envelope => { :body => { :create_response => { :results => { :status_message => message } } } } }
    double('raw', hash: data)
  end

  def build_empty_raw
    data = { :envelope => { :body => { :create_response => {}}}}
    double('raw', hash: data)
  end

  let(:inner_response) { double('FuelSDK::Response') }
  let(:triggered_send_response) { described_class.new(inner_response) }

  context '#success' do
    it 'returns false if the SOAP request was not successful' do
      expect(inner_response).to receive(:success).and_return(false)
      expect(triggered_send_response.success).to be false
    end

    it 'returns false if the SOAP request was successful but the raw response did not include a Results' do
      raw = build_empty_raw
      expect(inner_response).to receive(:raw).and_return(raw)
      expect(inner_response).to receive(:success).and_return(true)
      expect(triggered_send_response.success).to be false
    end

    it 'returns false if the SOAP request was successful but the TriggeredSend was not created' do
      raw = build_raw 'Incorrect Status Message'
      expect(inner_response).to receive(:raw).and_return(raw)
      expect(inner_response).to receive(:success).and_return(true)
      expect(triggered_send_response.success).to be false
    end

    it 'returns true if the SOAP request was successful and TriggeredSend was created' do
      raw = build_raw 'Created TriggeredSend'
      expect(inner_response).to receive(:raw).and_return(raw)
      expect(inner_response).to receive(:success).and_return(true)
      expect(triggered_send_response.success).to be true
    end

    it 'returns false if the SOAP request was successful but the status message wasnt "Created TriggeredSend"' do
      raw = build_raw 'banana'
      expect(inner_response).to receive(:raw).and_return(raw)
      expect(inner_response).to receive(:success).and_return(true)
      expect(triggered_send_response.success).to be false
    end

    it 'has an alias of success?' do
      expect(triggered_send_response.method(:success)).to eq(triggered_send_response.method(:success?))
    end

    it 'has an alias of status' do
      expect(triggered_send_response.method(:success)).to eq(triggered_send_response.method(:success?))
    end
  end

  context 'is a delegator' do
    it 'delegates to the FuelSDK::Response' do
      expect(triggered_send_response.__getobj__).to eq inner_response
    end
  end
end
