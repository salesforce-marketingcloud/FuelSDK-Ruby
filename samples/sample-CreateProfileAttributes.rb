require 'marketingcloudsdk'
require_relative 'sample_helper'

begin
	myclient = MarketingCloudSDK::Client.new auth
	
	## Example using CreateProfileAttributes() method
	
	NameOfAttributeOne = "ExampleAttributeOne"
	NameOfAttributeTwo = "ExampleAttributeTwo"

	# Declare a Ruby Hash which contain all of the details for a DataExtension
	profileAttrOne = {"Name" => NameOfAttributeOne, "PropertyType"=>"string", "Description"=>"New Attribute from the SDK", "IsRequired"=>"false", "IsViewable"=>"false", "IsEditable"=>"true", "IsSendTime"=>"false"}
	profileAttrTwo = {"Name" => NameOfAttributeTwo, "PropertyType"=>"string", "Description"=>"New Attribute from the SDK", "IsRequired"=>"false", "IsViewable"=>"false", "IsEditable"=>"true", "IsSendTime"=>"false"}
	
	# Call CreateDataExtensions passing in both DataExtension Hashes as an Array
	response = myclient.CreateProfileAttributes([profileAttrOne,profileAttrTwo])
	p 'Response Status: ' + response.status.to_s
	p 'Code: ' + response.code.to_s
	p 'Message: ' + response.message.to_s	
	p 'Results Length: ' + response.results.length.to_s
	p 'Results: ' + response.results.to_s
	
	p '>>> Delete profileAttrOne'
	profileattr = ET_ProfileAttribute.new 
	profileattr.authStub = myclient
	profileattr.props = {"Name" => NameOfAttributeOne}
	delResponse = profileattr.delete
	p 'Delete Status: ' + delResponse.status.to_s
	p 'Code: ' + delResponse.code.to_s
	p 'Message: ' + delResponse.message.to_s
	p 'Results: ' + delResponse.results.inspect
	
	p '>>> Delete profileAttrTwo'
	profileattr = ET_ProfileAttribute.new 
	profileattr.authStub = myclient
	profileattr.props = {"Name" => NameOfAttributeTwo}
	delResponse = profileattr.delete
	p 'Delete Status: ' + delResponse.status.to_s
	p 'Code: ' + delResponse.code.to_s
	p 'Message: ' + delResponse.message.to_s
	p 'Results: ' + delResponse.results.inspect
	
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

