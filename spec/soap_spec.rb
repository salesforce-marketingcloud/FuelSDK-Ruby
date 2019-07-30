require 'spec_helper'

describe MarketingCloudSDK::Soap do

  let(:client) { MarketingCloudSDK::Client.new }

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
  
  it { should respond_to(:package_name) }
  it { should respond_to(:package_name=) }
  
  it { should respond_to(:package_folders) }
  it { should respond_to(:package_folders=) }

  its(:debug) { should be false }
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
      subject {
        client.stub(:soap_request) do |action, message|
          [action, message]
        end

        client.stub_chain(:soap_describe,:editable)
          .and_return(['First Name', 'Last Name', 'Gender'])
        client
      }
      it 'formats soap :create message for single object' do
        expect(subject.soap_post 'Subscriber', 'EmailAddress' => 'test@fuelsdk.com' ).to eq([:create,
          {
            'Objects' => {'EmailAddress' => 'test@fuelsdk.com'},
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'formats soap :create message for multiple objects' do
        expect(subject.soap_post 'Subscriber', [{'EmailAddress' => 'first@fuelsdk.com'}, {'EmailAddress' => 'second@fuelsdk.com'}] ).to eq([:create,
          {
            'Objects' => [{'EmailAddress' => 'first@fuelsdk.com'}, {'EmailAddress' => 'second@fuelsdk.com'}],
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'formats soap :create message for single object with an attribute' do
        expect(subject.soap_post 'Subscriber', {'EmailAddress' => 'test@fuelsdk.com', 'Attributes'=> [{'Name'=>'First Name', 'Value'=>'first'}]}).to eq([:create,
          {
            'Objects' => {
              'EmailAddress' => 'test@fuelsdk.com',
              'Attributes' => [{'Name' => 'First Name', 'Value' => 'first'}],
            },
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'formats soap :create message for single object with multiple attributes' do
        expect(subject.soap_post 'Subscriber', {'EmailAddress' => 'test@fuelsdk.com',
          'Attributes'=> [{'Name'=>'First Name', 'Value'=>'first'}, {'Name'=>'Last Name', 'Value'=>'subscriber'}]}).to eq([:create,
          {
            'Objects' => {
              'EmailAddress' => 'test@fuelsdk.com',
              'Attributes' => [
                {'Name' => 'First Name', 'Value' => 'first'},
                {'Name' => 'Last Name', 'Value' => 'subscriber'},
              ],
            },
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end

      it 'formats soap :create message for multiple objects with multiple attributes' do
        expect(subject.soap_post 'Subscriber', [{'EmailAddress' => 'first@fuelsdk.com', 'Attributes'=> [{'Name'=>'First Name', 'Value'=>'first'}, {'Name'=>'Last Name', 'Value'=>'subscriber'}]},
          {'EmailAddress' => 'second@fuelsdk.com', 'Attributes'=> [{'Name'=>'First Name', 'Value'=>'second'}, {'Name'=>'Last Name', 'Value'=>'subscriber'}]}]).to eq([:create,
          {
            'Objects' => [
              {'EmailAddress' => 'first@fuelsdk.com',
                'Attributes' => [
                  {'Name' => 'First Name', 'Value' => 'first'},
                  {'Name' => 'Last Name', 'Value' => 'subscriber'},
                ]
              },
              {'EmailAddress' => 'second@fuelsdk.com',
                'Attributes' => [
                  {'Name' => 'First Name', 'Value' => 'second'},
                  {'Name' => 'Last Name', 'Value' => 'subscriber'},
                ]
              }],
            :attributes! => {'Objects' => {'xsi:type' => ('tns:Subscriber')}}
          }])
      end
    end
  end
end
