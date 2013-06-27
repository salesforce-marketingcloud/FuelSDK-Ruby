require 'spec_helper.rb'
require 'objects_helper_spec.rb'

describe FuelSDK::BounceEvent do

  let(:object) { FuelSDK::BounceEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'BounceEvent' }
end

describe FuelSDK::ClickEvent do

  let(:object) { FuelSDK::ClickEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ClickEvent' }
end

describe FuelSDK::ContentArea do

  let(:object) { FuelSDK::ContentArea.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'ContentArea' }
end

describe FuelSDK::DataFolder do

  let(:object) { FuelSDK::DataFolder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe FuelSDK::Folder do

  let(:object) { FuelSDK::Folder.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataFolder' }
end

describe FuelSDK::Email do

  let(:object) { FuelSDK::Email.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Email' }
end

describe FuelSDK::List do

  let(:object) { FuelSDK::List.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'List' }
end

describe FuelSDK::List::Subscriber do

  let(:object) { FuelSDK::List::Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'ListSubscriber' }
end

describe FuelSDK::OpenEvent do

  let(:object) { FuelSDK::OpenEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'OpenEvent' }
end

describe FuelSDK::SentEvent do

  let(:object) { FuelSDK::SentEvent.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'SentEvent' }
end

describe FuelSDK::Subscriber do

  let(:object) { FuelSDK::Subscriber.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'Subscriber' }
end

describe FuelSDK::DataExtension::Column do

  let(:object) { FuelSDK::DataExtension::Column.new }
  subject{ object }

  it_behaves_like 'Soap Read Only Object'
  its(:id){ should eq 'DataExtensionField' }
end

describe FuelSDK::DataExtension do
  let(:object) { FuelSDK::DataExtension.new }
  subject{ object }

  it_behaves_like 'Soap Object'
  its(:id){ should eq 'DataExtension' }
  it { should respond_to :columns= }
  it { should respond_to :fields }
  it { should respond_to :fields= }

  describe '#post' do
    subject {
      object.stub_chain(:client, :soap_post) do |id, properties|
        [id, properties]
      end

      object
    }

    it 'raises an error when it has a list of properties and fields' do
      subject.fields = [{'Name' => 'Name'}]
      subject.properties = [{'Name' => 'Some DE'}]
      expect{subject.post}.to raise_error(
        'Unable to handle muliple DataExtension definitions and a field definition')
    end

    it 'fields must be empty if not nil' do
      subject.fields = []
      subject.properties = [{'Name' => 'Some DE', 'fields' => [{'Name' => 'A field'}]}]
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

    it 'DataExtension can be created using properties and fields accessors' do
      subject.fields = [{'Name' => 'A field'}]
      subject.properties = {'Name' => 'Some DE'}
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

    it 'DataExtension fields can be apart of the DataExtention properties' do
      subject.properties = {'Name' => 'Some DE', 'Fields' => {'Field' => [{'Name' => 'A field'}]}}
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
          [{
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }]
        ])
    end

    it 'DataExtension definitions will translate columns entry to correct format' do
      subject.properties = {'Name' => 'Some DE', 'columns' => [{'Name' => 'A field'}]}
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

    it 'supports columns attribute for a single DataExtension definition' do
      subject.columns = [{'Name' => 'A field'}]
      subject.properties = {'Name' => 'Some DE'}
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
        subject.properties = {'Name' => 'Some DE', 'Fields' => {'Field' => [{'Name' => 'A field'}]}}
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in properties explicitly and with columns key' do
        subject.properties = {'Name' => 'Some DE',
          'columns' => [{'Name' => 'A fields'}],
          'Fields' => {'Field' => [{'Name' => 'A field'}]
        }}
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in properties explicitly and with fields key' do
        subject.properties = {'Name' => 'Some DE',
          'fields' => [{'Name' => 'A fields'}],
          'Fields' => {'Field' => [{'Name' => 'A field'}]
        }}
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in with fields and colums key' do
        subject.properties = {'Name' => 'Some DE',
          'fields' => [{'Name' => 'A fields'}],
          'columns' => [{'Name' => 'A field'}]
        }
        expect{subject.post}.to raise_error 'Fields are defined in too many ways. Please only define once.'
      end
      it 'when defined in with fields key and accessor' do
        subject.fields = [{'Name' => 'A field'}]
        subject.properties = {'Name' => 'Some DE',
          'fields' => [{'Name' => 'A fields'}]
        }
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
          [{
            'Name' => 'Some DE',
            'Fields' => {
              'Field' => [{'Name' => 'A field'}]
            }
          }]
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
