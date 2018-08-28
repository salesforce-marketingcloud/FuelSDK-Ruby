require 'spec_helper.rb'
require 'objects_helper_spec.rb'

describe MarketingCloudSDK::Objects::Base do

  let(:object) { MarketingCloudSDK::Objects::Base.new }
  subject{ object }

  describe '#properties' do
    it 'is empty by default' do
      expect(object.properties).to be_nil
    end

    it 'returns object when assigned an object' do
      object.properties = {'name' => 'value'}
      expect(object.properties).to eq({'name' => 'value'})
    end

    it 'returns array when assigned array' do
      object.properties = [{'name' => 'value'}]
      expect(object.properties).to eq([{'name' => 'value'}])
    end
  end

end

describe MarketingCloudSDK::BounceEvent do

  let(:object) { MarketingCloudSDK::BounceEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'BounceEvent' }
end

describe MarketingCloudSDK::ClickEvent do

  let(:object) { MarketingCloudSDK::ClickEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ClickEvent' }
end

describe MarketingCloudSDK::ContentArea do

  let(:object) { MarketingCloudSDK::ContentArea.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'ContentArea' }
end

describe MarketingCloudSDK::DataFolder do

  let(:object) { MarketingCloudSDK::DataFolder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe MarketingCloudSDK::Folder do

  let(:object) { MarketingCloudSDK::Folder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe MarketingCloudSDK::Email do

  let(:object) { MarketingCloudSDK::Email.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Email' }
end

describe MarketingCloudSDK::List do

  let(:object) { MarketingCloudSDK::List.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'List' }
end

describe MarketingCloudSDK::List::Subscriber do

  let(:object) { MarketingCloudSDK::List::Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ListSubscriber' }
end

describe MarketingCloudSDK::OpenEvent do

  let(:object) { MarketingCloudSDK::OpenEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'OpenEvent' }
end

describe MarketingCloudSDK::SentEvent do

  let(:object) { MarketingCloudSDK::SentEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'SentEvent' }
end

describe MarketingCloudSDK::Subscriber do

  let(:object) { MarketingCloudSDK::Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Subscriber' }
end

describe MarketingCloudSDK::DataExtension::Column do

  let(:object) { MarketingCloudSDK::DataExtension::Column.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'DataExtensionField' }
end

describe MarketingCloudSDK::DataExtension do
  let(:object) { MarketingCloudSDK::DataExtension.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataExtension' }
  it { should respond_to :columns= }
  it { should respond_to :fields }
  it { should respond_to :fields= }

  describe '#post' do
    subject {
		object.stub_chain(:client,:soap_post) do |id, properties|
			[id, properties]
		end
		object.stub_chain(:client,:package_name).and_return(nil)
		object.stub_chain(:client,:package_folders).and_return(nil)

      object
    }

    # maybe one day will make it smart enough to zip properties and fields if count is same?
    it 'raises an error when it has a list of properties and fields' do
      subject.fields = [{'Name' => 'Name'}]
      subject.properties = [{'Name' => 'Some DE'}, {'Name' => 'Some DE'}]
      expect{subject.post}.to raise_error(
        'Unable to handle muliple DataExtension definitions and a field definition')
    end

    it 'fields must be empty if not nil' do
      subject.fields = []
      subject.properties = {'Name' => 'Some DE', 'fields' => [{'Name' => 'A field'}]}
      expect(subject.post).to eq(
        [
          'DataExtension',
          {
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }
        ])
    end

    it 'DataExtension can be created using properties and fields accessors' do
      subject.fields = [{'Name' => 'A field'}]
      subject.properties = {'Name' => 'Some DE'}
      expect(subject.post).to eq(
        [
          'DataExtension',
          {
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }
        ])
    end

    it 'DataExtension fields can be apart of the DataExtention properties' do
      subject.properties = [{'Name' => 'Some DE', 'Fields' => {'Field' => [{'Name' => 'A field'}]}}]
      expect(subject.post).to eq(
        [
          'DataExtension',
          [{
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }]
        ])
    end

    it 'List of DataExtension definitions can be passed' do
      subject.properties = [{'Name' => 'Some DE', 'Fields' => {'Field' => [{'Name' => 'A field'}]}},
        {'Name' => 'Another DE', 'Fields' => {'Field' => [{'Name' => 'A second field'}]}}]
      expect(subject.post).to eq(
        [
          'DataExtension',
          [{
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          },{
            'Name' => 'Another DE',
            'Fields' => {
              'Field' => [{'Name' => 'A second field'}]
            }
          }]
        ])
    end

    it 'DataExtension definitions will translate fields entry to correct format' do
      subject.properties = {'Name' => 'Some DE', 'fields' => [{'Name' => 'A field'}]}
      expect(subject.post).to eq(
        [
          'DataExtension',
          {
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }
        ])
    end

    it 'DataExtension definitions will translate columns entry to correct format' do
      subject.properties = {'Name' => 'Some DE', 'columns' => [{'Name' => 'A field'}]}
      expect(subject.post).to eq(
        [
          'DataExtension',
          {
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }
        ])
    end

    it 'supports columns attribute for a single DataExtension definition' do
      subject.columns = [{'Name' => 'A field'}]
      subject.properties = [{'Name' => 'Some DE'}]
      expect(subject.post).to eq(
        [
          'DataExtension',
          [{
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }]
        ])
    end

    describe 'fields are defined twice' do
      it 'when defined in properties and by fields' do
        subject.fields = [{'Name' => 'A field'}]
        subject.properties = [{'Name' => 'Some DE', 'Fields' => {'Field' => [{'Name' => 'A field'}]}}]
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in properties explicitly and with columns key' do
        subject.properties =[{'Name' => 'Some DE',
          'columns' => [{'Name' => 'A fields'}],
          'Fields' => {'Field' => [{'Name' => 'A field'}]
        }}]
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in properties explicitly and with fields key' do
        subject.properties = [{'Name' => 'Some DE',
          'fields' => [{'Name' => 'A fields'}],
          'Fields' => {'Field' => [{'Name' => 'A field'}]
        }}]
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in with fields and colums key' do
        subject.properties = [{'Name' => 'Some DE',
          'fields' => [{'Name' => 'A fields'}],
          'columns' => [{'Name' => 'A field'}]
        }]
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in with fields key and accessor' do
        subject.fields = [{'Name' => 'A field'}]
        subject.properties = [{'Name' => 'Some DE',
          'fields' => [{'Name' => 'A fields'}]
        }]
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
    end
  end

  describe '#patch' do
    subject {
      object.stub_chain(:client, :soap_patch) do |id, properties|
        [id, properties]
      end

      object
    }

    it 'DataExtension can be created using properties and fields accessors' do
      subject.fields = [{'Name' => 'A field'}]
      subject.properties = {'Name' => 'Some DE'}
      expect(subject.patch).to eq(
        [
          'DataExtension',
          {
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }
        ])
    end
  end
end

describe MarketingCloudSDK::DataExtension::Row do
  let(:object) { MarketingCloudSDK::DataExtension::Row.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataExtensionObject' }
  it { should respond_to :name }
  it { should respond_to :name= }
  it { should respond_to :customer_key }
  it { should respond_to :customer_key= }

  describe '#name' do
    it 'raises error when missing both name and customer key' do
      expect{ subject.name }.to raise_error('Unable to process DataExtension::Row '\
        'request due to missing CustomerKey and Name')
    end

    it 'returns value' do
      subject.name = 'name'
      expect( subject.name ).to eq 'name'
    end
  end

  describe '#customer_key' do
    it 'raises error when missing both name and customer key' do
      expect{ subject.customer_key }.to raise_error('Unable to process DataExtension::Row '\
        'request due to missing CustomerKey and Name')
    end

    it 'returns value' do
      subject.customer_key = 'key'
      expect( subject.customer_key ).to eq 'key'
    end
  end

  describe '#retrieve_required' do
    it 'raises error when missing both name and customer key' do
      expect{ subject.send(:retrieve_required)}.to raise_error('Unable to process DataExtension::Row '\
        'request due to missing CustomerKey and Name')
      expect{ subject.name }.to raise_error('Unable to process DataExtension::Row '\
        'request due to missing CustomerKey and Name')
    end

    it 'updates missing' do
      rsp = double(MarketingCloudSDK::SoapResponse)
      rsp.stub(:results).and_return([{:name => 'Products', :customer_key => 'ProductsKey'}])
      rsp.stub(:success?).and_return true

      subject.stub_chain(:client,:soap_get).and_return(rsp)
      subject.name = 'Not Nil'

      # this really wouldn't work this way. name shouldn't be updated since its whats being used for filter,
      # but its a good test to show retrieve_required being fired
      expect(subject.name).to eq 'Not Nil' # not fired
      expect(subject.customer_key).to eq 'ProductsKey' # fired... stubbed get returns customer_key and name for update
      expect(subject.name).to eq 'Products' # returned name
    end
  end

  describe '#get' do
    subject {
      object.stub_chain(:client, :soap_get) do |id, properties, filter|
        [id, properties, filter]
      end

      object
    }

    it 'passes id including name to super get' do
      subject.name = 'Justin'
      expect(subject.get).to eq(['DataExtensionObject[Justin]', nil, nil])
    end
  end

  describe '#post' do
    subject {
      object.stub_chain(:client, :soap_post) do |id, properties|
        [id, properties]
      end

      object
    }

    it 'raises an error when missing both name and customer key' do
      subject.properties = [{'Name' => 'Some DE'}, {'Name' => 'Some DE'}]
      expect{subject.post}.to raise_error('Unable to process DataExtension::Row ' \
        'request due to missing CustomerKey and Name')
    end

    it 'uses explicitly defined properties' do
      subject.properties = [{'CustomerKey' => 'Subscribers',
        'Properties' => {'Property' => [{'Name' => 'Name', 'Value' => 'Justin'}]}}]
      expect(subject.post).to eq([
        'DataExtensionObject', [{
          'CustomerKey' => 'Subscribers',
          'Properties' => {'Property' => [{'Name' => 'Name', 'Value' => 'Justin'}]}}]
      ])
    end

    it 'inserts customer key into properties when set using accessor' do
      subject.customer_key = 'Subscribers'
      subject.properties = [{'Properties' => {
        'Property' => [{'Name' => 'Name', 'Value' => 'Justin'}]}}]
      expect(subject.post).to eq([
        'DataExtensionObject', [{
          'CustomerKey' => 'Subscribers',
          'Properties' => {'Property' => [{'Name' => 'Name', 'Value' => 'Justin'}]}}]
      ])
    end

    it 'uses name to get customer key for inseration' do
      subject.name = 'Subscribers'

      rsp = double(MarketingCloudSDK::SoapResponse)
      rsp.stub(:results).and_return([{:name => 'Products', :customer_key => 'ProductsKey'}])
      rsp.stub(:success?).and_return true

      subject.stub_chain(:client, :soap_get).and_return(rsp)
      subject.properties = [{'Properties' => {
        'Property' => [{'Name' => 'Name', 'Value' => 'Justin'}]}}]

      expect(subject.post).to eq([
        'DataExtensionObject', [{
          'CustomerKey' => 'ProductsKey',
          'Properties' => {'Property' => [{'Name' => 'Name', 'Value' => 'Justin'}]}}]
      ])
    end

    it 'correctly formats array property' do
      subject.customer_key = 'Subscribers'

      subject.properties = [{'Name' => 'Justin'}]

      expect(subject.post).to eq([
        'DataExtensionObject', [{
          'CustomerKey' => 'Subscribers',
          'Properties' => {'Property' => [{'Name' => 'Name', 'Value' => 'Justin'}]}}]
      ])
    end
  end
end

# verify backward compats
describe ET_Subscriber do

  let(:object) { ET_Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Subscriber' }
end
