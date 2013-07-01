require 'spec_helper'
describe FuelSDK::Rest do
  let(:client) { FuelSDK::Client.new }

  subject { client }
  it { should respond_to(:rest_get) }
  it { should respond_to(:rest_client) }
  it { should respond_to(:complete_url) }

  describe '#complete_url' do
    it 'raises an exception when identities are missing' do
      expect { client.complete_url "some_url/%{parent}/%{child}", {parent: 1} }.to raise_exception 'key{child} not found to complete some_url/%{parent}/%{child}'
    end

    it 'returns url with all identities replaced' do
      expect( client.complete_url "some_url/%{parent}/%{child}", {:parent => 1, :child => 2} ).to eq 'some_url/1/2'
    end

    it 'handles identities with string keys' do
      expect( client.complete_url "some_url/%{parent}/%{child}", {'parent'=> 1, 'child'=> 2} ).to eq 'some_url/1/2'
    end

    it 'treats empty values as optional keys' do
      expect( client.complete_url "some_url/%{parent}/%{child}", {'parent'=> 1, 'child'=> ''} ).to eq 'some_url/1'
    end

    it 'handles extra keys' do
      expect( client.complete_url "some_url/%{parent}/%{child}", {'parent'=> 1, 'child'=> '', 'other' => 1} ).to eq 'some_url/1'
    end
  end

  describe '#get_url_properties' do
    it 'returns hash of properties in format string' do
      expect( client.get_url_properties "some_url/%{parent}/%{child}", {'parent'=> 1, 'child'=> '', 'other' => 1} ).to eq({'parent' => 1, 'child' => ''})
    end

    it 'handles missing url properties' do
      expect( client.get_url_properties "some_url/%{parent}/%{child}", {'parent'=> 1, 'other' => 1} ).to eq({'parent' => 1})
    end

    it 'filters url properties from properties leaving query params' do
      properties = {'parent'=> 1, 'other' => 1}
      client.get_url_properties "some_url/%{parent}/%{child}", properties
      expect(properties).to eq 'other' => 1
    end
  end

end
