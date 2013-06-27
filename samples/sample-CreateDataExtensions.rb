require 'fuelsdk'
require_relative 'sample_helper'

begin
	myclient = ET_Client.new auth

	## Example using CreateDataExtensions() method

	# Declare a Ruby Hash which contain all of the details for a DataExtension
	deOne = {"Name" => "HelperDEOne","CustomerKey" => "HelperDEOne"}
	deOne['columns'] = [{"Name" => "Name", "FieldType" => "Text", "IsPrimaryKey" => "true", "MaxLength" => "100", "IsRequired" => "true"},{"Name" => "OtherField", "FieldType" => "Text"}]

	# Declare a 2nd Ruby Hash which contain all of the details for a DataExtension
	deTwo = {"Name" => "HelperDETwo","CustomerKey" => "HelperDETwo"}
	deTwo['columns'] = [{"Name" => "Name", "FieldType" => "Text", "IsPrimaryKey" => "true", "MaxLength" => "100", "IsRequired" => "true"},{"Name" => "OtherField", "FieldType" => "Text"}]

	# Call CreateDataExtensions passing in both DataExtension Hashes as an Array
	createDEResponse = myclient.CreateDataExtensions([deOne, deTwo])
	p 'CreateDataExtensions Status: ' + createDEResponse.status.to_s
	p 'Code: ' + createDEResponse.code.to_s
	p 'Message: ' + createDEResponse.message.to_s
	p 'Results Length: ' + createDEResponse.results.length.to_s
	p 'Results: ' + createDEResponse.results.to_s
  raise 'Failure creating data extensions' unless createDEResponse.success?
  raise 'Failure creating data extensions' unless createDEResponse.results.count == 2

	# Cleaning up the newly created DEs
	# Delete deOne
	p '>>> Delete deOne'
	de5 = ET_DataExtension.new
	de5.authStub = myclient
	de5.props = {"CustomerKey" => "HelperDEOne"}
	delResponse = de5.delete
	p 'Delete Status: ' + delResponse.status.to_s
	p 'Code: ' + delResponse.code.to_s
	p 'Message: ' + delResponse.message.to_s
	p 'Results: ' + delResponse.results.inspect

	# Delete deTwo
	p '>>> Delete deTwo'
	de5 = ET_DataExtension.new
	de5.authStub = myclient
	de5.props = {"CustomerKey" => "HelperDETwo"}
	delResponse = de5.delete
	p 'Delete Status: ' + delResponse.status.to_s
	p 'Code: ' + delResponse.code.to_s
	p 'Message: ' + delResponse.message.to_s
	p 'Results: ' + delResponse.results.inspect

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

