#require 'spec_helper'
#
#describe 'indifferent_access' do
#
#  it 'returns value when symbol is used to access a string key' do
#    expect( indifferent_access :key, 'key' => true).to be_true
#  end
#  it 'returns value when string is used to access a symbol key' do
#    expect( indifferent_access 'key', :key => true).to be_true
#  end
#end
