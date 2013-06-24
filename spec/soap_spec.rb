require 'spec_helper'

describe FuelSDK::Soap do

  let(:client) { FuelSDK::Client.new }

  subject { client }

  it { should respond_to(:soap_get) }
  it { should respond_to(:soap_post) }
  it { should respond_to(:soap_patch) }
  it { should respond_to(:soap_delete) }
  it { should respond_to(:soap_describe) }

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

  describe 'requests' do
    subject {
      client.stub(:soap_request) do |action, message|
        [action, message]
      end
      client
    }

    it '#soap_describe calls client with :describe and DescribeRequests message' do
      expect(subject.soap_describe 'Subscriber').to eq([:describe,
        {'DescribeRequests' => {'ObjectDefinitionRequest' => {'ObjectType' => 'Subscriber' }}}])
    end

    describe '#soap_post' do
      it 'calls client with :create and Object properties message' do
        expect(subject.soap_post 'Subscriber', 'EmailAddress' => 'test@kevy.com' ).to eq([:create,
          {
            'Objects' => {'EmailAddress' => 'test@kevy.com'},
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'handles creating multiple Objects' do
        expect(subject.soap_post 'Subscriber', [{'EmailAddress' => 'first@kevy.com'}, {'EmailAddress' => 'second@kevy.com'}] ).to eq([:create,
          {
            'Objects' => [{'EmailAddress' => 'first@kevy.com'}, {'EmailAddress' => 'second@kevy.com'}],
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'handles attributes in Object properties message' do
        expect(subject.soap_post 'Subscriber', {'EmailAddress' => 'test@kevy.com'}, {"First Name" => "Kevy"} ).to eq([:create,
          {
            'Objects' => {
              'EmailAddress' => 'test@kevy.com',
              'Attributes' => [{'Name' => 'First Name', 'Value' => 'Kevy'}],
            },
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'handles multiple attributes in Object properties message' do
        expect(subject.soap_post 'Subscriber', {'EmailAddress' => 'test@kevy.com'},
          {"First Name" => "Kevy", "Last Name" => "Kid"}).to eq([:create,
          {
            'Objects' => {
              'EmailAddress' => 'test@kevy.com',
              'Attributes' => [
                {'Name' => 'First Name', 'Value' => 'Kevy'},
                {'Name' => 'Last Name', 'Value' => 'Kid'},
              ],
            },
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'attributes are ignored for multiple objects' do
        expect(subject.soap_post 'Subscriber', [{'EmailAddress' => 'first@kevy.com'}, {'EmailAddress' => 'second@kevy.com'}],
          {"First Name" => "Kevy", "Last Name" => "Kid"}).to eq([:create,
          {
            'Objects' => [{ 'EmailAddress' => 'first@kevy.com', }, { 'EmailAddress' => 'second@kevy.com', }],
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end
    end
  end
end
