require '../ET_Client.rb'


begin 
	stubObj = ET_Client.new(false, false)


	# Get all of the DataExtensions in an Account
	p '>>> Get all of the DataExtensions in an Account'
	de = ET_DataExtension.new
	de.authStub = stubObj
	de.props = ["CustomerKey", "Name"]
	getResponse = de.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s

	# Specify a name for the data extension that will be used for testing 
	# Note: Name and CustomerKey will be the same value
	# WARNING: Data Extension will be deleted so don't use the name of a
	# production data extension 
	NameOfDE = "ThisWillBeDeleted-Test"

	# Create  Data Extension
	p '>>> Create Data Extension'
	de2 = ET_DataExtension.new 
	de2.authStub = stubObj
	de2.props = {"Name" => NameOfDE,"CustomerKey" => NameOfDE}
	de2.columns = [{"Name" => "Name", "FieldType" => "Text", "IsPrimaryKey" => "true", "MaxLength" => "100", "IsRequired" => "true"},{"Name" => "OtherField", "FieldType" => "Text"}]
	postResponse = de2.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.inspect

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
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s


	# Add a row to a data extension (using CustomerKey)
	p '>>>  Add a row to a data extension'
	de4 = ET_DataExtension::Row.new 
	de4.CustomerKey = NameOfDE;
	de4.authStub = stubObj
	de4.props = {"Name" => "Test3", "OtherField" => "Text3"}
	postResponse = de4.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.inspect

	# Add a row to a data extension (Using Name)
	p '>>> Add a row to a data extension'
	de4 = ET_DataExtension::Row.new 
	de4.authStub = stubObj
	de4.Name = NameOfDE
	de4.props = {"Name" => "Test4", "OtherField" => "Text3"}
	postResponse = de4.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.inspect
	
	# Add a row in a data extension using Put method
	p '>>>  Add a row in a data extension using Put method'
	de5 = ET_DataExtension::Row.new 
	de5.CustomerKey = NameOfDE;
	de5.authStub = stubObj
	de5.props = {"Name" => "Test5", "OtherField" => "Some Text"}
	putResponse = de5.put
	p 'Put Status: ' + putResponse.status.to_s
	p 'Code: ' + putResponse.code.to_s
	p 'Message: ' + putResponse.message.to_s
	p 'Results: ' + putResponse.results.inspect
	
	# Update a row in a data extension using Put method
	p '>>>  Update a row in a data extension using Put method'
	de6 = ET_DataExtension::Row.new 
	de6.CustomerKey = NameOfDE;
	de6.authStub = stubObj
	de6.props = {"Name" => "Test5", "OtherField" => "Some More Text"}
	putResponse = de6.put
	p 'Put Status: ' + putResponse.status.to_s
	p 'Code: ' + putResponse.code.to_s
	p 'Message: ' + putResponse.message.to_s
	p 'Results: ' + putResponse.results.inspect

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
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s

	# Update a row in  a data extension
	p '>>> Update a row in  a data extension'
	de4 = ET_DataExtension::Row.new 
	de4.authStub = stubObj
	de4.CustomerKey = NameOfDE
	de4.props = {"Name" => "Test3", "OtherField" => "UPDATED!"}
	postResponse = de4.patch
	p 'Patch Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.inspect

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
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s

	# Delete a row from a data extension
	p '>>> Delete a row from a data extension'
	de4 = ET_DataExtension::Row.new 
	de4.authStub = stubObj
	de4.CustomerKey = NameOfDE
	de4.props = {"Name" => "Test3"}
	deleteResponse = de4.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s
	p 'Results: ' + deleteResponse.results.inspect

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

=begin
	# Retrieve lots of rows with moreResults
	p '>>> Retrieve lots of rows with moreResults'
	row = ET_DataExtension::Row.new()
	row.authStub = stubObj
	row.Name = "zipstolong"
	row.props = ["zip","latitude","longitude"]
	getResponse = row.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s

	while getResponse.moreResults do 
		p '>>> Continue Retrieve lots of rows with moreResults'
		getResponse = row.getMoreResults
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end 
=end

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace
end
