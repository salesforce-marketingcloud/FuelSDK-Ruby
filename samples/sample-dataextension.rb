require 'fuelsdk'
require_relative 'sample_helper'
require 'pry'

begin
	stubObj = ET_Client.new auth
	
	# Specify a name for the data extension that will be used for testing
	# Note: Name and CustomerKey will be the same value
	# WARNING: Data Extension will be deleted so don't use the name of a
	# production data extension
	NameOfDE = "ThisWillBeDeleted-Testz"
	
	# Get all of the DataExtensions in an Account
	p '>>> Get all of the DataExtensions in an Account'
	de = ET_DataExtension.new
	de.authStub = stubObj
	de.props = ["CustomerKey", "Name"]
	getResponse = de.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving data extensions' unless getResponse.success?

	# Create  Data Extension
	p '>>> Create Data Extension'
	de2 = ET_DataExtension.new
	de2.authStub = stubObj
	de2.props = {"Name" => NameOfDE,"CustomerKey" => NameOfDE}
	de2.columns = [{"Name" => "Name", "FieldType" => "Text", "IsPrimaryKey" => "true", "MaxLength" => "100", "IsRequired" => "true"},
  {"Name" => "OtherField", "FieldType" => "Text"}]
	postResponse = de2.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.inspect
  raise 'Failure creating data extension' unless postResponse.success?

	# Update DE to add new field
	p '>>> Update DE to add new field'
	de3 = ET_DataExtension.new
	de3.authStub = stubObj
	de3.props = {"Name" => NameOfDE,"CustomerKey" => NameOfDE}
	de3.columns = [{"Name" => "AddedField", "FieldType" => "Text"}]
	patchResponse = de3.patch
	p 'Patch Status: ' + patchResponse.status.to_s
	p 'Code: ' + patchResponse.code.to_s
	p 'Message: ' + patchResponse.message.to_s
	p 'Results: ' + patchResponse.results.inspect
  raise 'Failure updating data extension' unless patchResponse.success?

	# Retrieve all columns for data extension
	p '>>> Retrieve all columns for data extension '
	myDEColumn = ET_DataExtension::Column.new
	myDEColumn.authStub = stubObj
	myDEColumn.props = ["Name"]
	myDEColumn.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfDE}
	getResponse = myDEColumn.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving data extension columns' unless getResponse.success?
  raise 'Failure retrieving correct number of data extension columns' unless getResponse.results.count == 3

	# Add a row to a data extension (using CustomerKey)
	p '>>>  Add a row to a data extension'
	de4 = ET_DataExtension::Row.new
	de4.CustomerKey = NameOfDE;
	de4.authStub = stubObj
	de4.props = {"Name" => "MAC3", "OtherField" => "Text3"}
	postResponse = de4.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.inspect
  raise 'Failure creating data extension row' unless postResponse.success?

	# Add a row to a data extension (Using Name)
	p '>>> Add a row to a data extension'
	de4 = ET_DataExtension::Row.new
	de4.authStub = stubObj
	de4.Name = NameOfDE
	de4.props = {"Name" => "MAC4", "OtherField" => "Text3"}
	postResponse = de4.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.inspect
  raise 'Failure creating data extension row' unless postResponse.success?

	# Retrieve all rows
	p '>>> Retrieve all rows'
	row = ET_DataExtension::Row.new()
	row.authStub = stubObj
	row.CustomerKey = NameOfDE
	row.props = ["Name","OtherField"]
	getResponse = row.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving data extension rows' unless getResponse.success?
  raise 'Failure retrieving correct number of data extension rows' unless getResponse.results.count == 2

	# Update a row in  a data extension
	p '>>> Update a row in  a data extension'
	de4 = ET_DataExtension::Row.new
	de4.authStub = stubObj
	de4.CustomerKey = NameOfDE
	de4.props = {"Name" => "MAC3", "OtherField" => "UPDATED!"}
	patchResponse = de4.patch
	p 'Patch Status: ' + patchResponse.status.to_s
	p 'Code: ' + patchResponse.code.to_s
	p 'Message: ' + patchResponse.message.to_s
	p 'Results: ' + patchResponse.results.inspect
  raise 'Failure updating data extension row' unless patchResponse.success?

	# Retrieve only updated row
	p '>>> Retrieve only updated row'
	row = ET_DataExtension::Row.new()
	row.authStub = stubObj
	row.CustomerKey = NameOfDE
	row.props = ["Name","OtherField"]
	row.filter = {'Property' => 'Name','SimpleOperator' => 'equals','Value' => 'MAC3'}
	getResponse = row.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving data extension rows' unless getResponse.success?

	# Delete a row from a data extension
	p '>>> Delete a row from a data extension'
	de4 = ET_DataExtension::Row.new
	de4.authStub = stubObj
	de4.CustomerKey = NameOfDE
	de4.props = {"Name" => "MAC3"}
	deleteResponse = de4.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s
	p 'Results: ' + deleteResponse.results.inspect
  raise 'Failure deleting data extension row' unless deleteResponse.success?

	# Delete a Data Extension
	p '>>> Delete a  Data Extension'
	de5 = ET_DataExtension.new
	de5.authStub = stubObj
	de5.props = {"Name" => NameOfDE,"CustomerKey" => NameOfDE}
	delResponse = de5.delete
	p 'Post Status: ' + delResponse.status.to_s
	p 'Code: ' + delResponse.code.to_s
	p 'Message: ' + delResponse.message.to_s
	p 'Results: ' + delResponse.results.inspect
  raise 'Failure deleting data extension' unless deleteResponse.success?

=begin
	# Retrieve lots of rows with more?
	p '>>> Retrieve lots of rows with more?'
	row = ET_DataExtension::Row.new()
	row.authStub = stubObj
	row.Name = "zipstolong"
	row.props = ["zip","latitude","longitude"]
	getResponse = row.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving data extension rows' unless getResponse.success?

	while getResponse.more? do
		p '>>> Continue Retrieve lots of rows with more?'
		getResponse = row.getMoreResults
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end
=end

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace

  de5 = ET_DataExtension.new
  de5.authStub = stubObj
  de5.props = {"Name" => NameOfDE,"CustomerKey" => NameOfDE}
  de5.delete

end
