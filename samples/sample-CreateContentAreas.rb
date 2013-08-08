require 'fuelsdk'
require_relative 'sample_helper'

begin
	myclient = FuelSDK::Client.new auth
	
	## Example using CreateContentAreas() method
	
	NameOfContentAreaOne = "ExampleContentAreaOne"
	NameOfContentAreaTwo = "ExampleContentAreaTwo"

	# Declare a Ruby Hash which contain all of the details for a DataExtension
	contAreaOne = {"CustomerKey" => NameOfContentAreaOne, "Name"=>NameOfContentAreaOne, "Content"=> "<b>Some HTML Content Goes here</b>"}
	contAreaTwo = {"CustomerKey" => NameOfContentAreaTwo, "Name"=>NameOfContentAreaTwo, "Content"=> "<b>Some Different HTML Content Goes here</b>"}
	
	# Call CreateDataExtensions passing in both DataExtension Hashes as an Array
	response = myclient.CreateContentAreas([contAreaOne,contAreaTwo])
	p 'Response Status: ' + response.status.to_s
	p 'Code: ' + response.code.to_s
	p 'Message: ' + response.message.to_s	
	p 'Results Length: ' + response.results.length.to_s
	p 'Results: ' + response.results.to_s

	p '>>> Delete contAreaOne'
	contArea = ET_ContentArea.new 
	contArea.authStub = myclient
	contArea.props = {"CustomerKey" => NameOfContentAreaOne}
	delResponse = contArea.delete
	p 'Delete Status: ' + delResponse.status.to_s
	p 'Code: ' + delResponse.code.to_s
	p 'Message: ' + delResponse.message.to_s
	p 'Results: ' + delResponse.results.inspect
	
	p '>>> Delete contAreaTwo'
	contArea = ET_ContentArea.new 
	contArea.authStub = myclient
	contArea.props = {"CustomerKey" => NameOfContentAreaTwo}
	delResponse = contArea.delete
	p 'Delete Status: ' + delResponse.status.to_s
	p 'Code: ' + delResponse.code.to_s
	p 'Message: ' + delResponse.message.to_s
	p 'Results: ' + delResponse.results.inspect
	
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

