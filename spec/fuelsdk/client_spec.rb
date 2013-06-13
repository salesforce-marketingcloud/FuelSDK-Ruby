#require 'spec_helper'
#
#describe FuelSDK::Client do
#
#  it 'errors when instantiated with clientsecret but without clientid' do
#    expect { FuelSDK::Client.new :clientid => 'id' }.to raise_error
#  end
#
#  it 'errors when instantiated with clientid but without clientsecret' do
#    expect { FuelSDK::Client.new :clientid => 'id' }.to raise_error
#  end
#
#  describe '#new' do
#    let(:client) { FuelSDK::Client.new :clientid => 'id', :clientsecret => 'secret' }
#    subject { client }
#
#    its(:id) { should eq 'id' }
#    its(:secret) { should eq 'secret' }
#  end
#
#end
