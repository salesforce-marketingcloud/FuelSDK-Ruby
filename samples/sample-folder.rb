require 'fuelsdk'
require_relative 'sample_helper'

begin
	stubObj = FuelSDK::Client.new auth

	# Retrieve All Folder with GetMoreResults
	p '>>> Retrieve All Folder with GetMoreResults'
	getFolder = FuelSDK::Folder.new()
	getFolder.authStub = stubObj
	getFolder.props = ["ID", "Client.ID", "ParentFolder.ID", "ParentFolder.CustomerKey", "ParentFolder.ObjectID", "ParentFolder.Name", "ParentFolder.Description", "ParentFolder.ContentType", "ParentFolder.IsActive", "ParentFolder.IsEditable", "ParentFolder.AllowChildren", "Name", "Description", "ContentType", "IsActive", "IsEditable", "AllowChildren", "CreatedDate", "ModifiedDate", "Client.ModifiedBy", "ObjectID", "CustomerKey", "Client.EnterpriseID", "Client.CreatedBy"]
	getResponse = getFolder.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s
	raise 'Failure retrieving Folders' unless getResponse.success?

	while getResponse.more? do
		p '>>> Continue Retrieve All Folder with GetMoreResults'
		getResponse.continue
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end

	NameOfTestFolder = "RubySDKFolder"

	# Retrieve Specific Folder for Email Folder ParentID
	p '>>> Retrieve Specific Folder for Email Folder ParentID'
	getFolder = FuelSDK::Folder.new()
	getFolder.authStub = stubObj
	getFolder.props = ["ID"]
	getFolder.filter = {'LeftOperand' => {'Property' => 'ParentFolder.ID','SimpleOperator' => 'equals','Value' => '0'}, 'LogicalOperator' => 'AND', 'RightOperand' => {'Property' => 'ContentType','SimpleOperator' => 'equals','Value' => 'EMAIL'}}
	getResponse = getFolder.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
	raise 'Failure retrieving Folder' unless getResponse.success?

	if getResponse.success? then
		ParentIDForEmail = getResponse.results[0][:id]
		p "Parent Folder for Email: #{ParentIDForEmail}"

		# Create Folder
		p '>>> Create Folder'
		postFolder = FuelSDK::Folder.new
		postFolder.authStub = stubObj
		postFolder.props = {"CustomerKey" => NameOfTestFolder, "Name" => NameOfTestFolder, "Description" => NameOfTestFolder, "ContentType"=> "EMAIL", "ParentFolder" => {"ID" => ParentIDForEmail}}
		postResponse = postFolder.post
		p 'Post Status: ' + postResponse.status.to_s
		p 'Code: ' + postResponse.code.to_s
		p 'Message: ' + postResponse.message.to_s
		p 'Result Count: ' + postResponse.results.length.to_s
		p 'Results: ' + postResponse.results.inspect
    raise 'Failure creating Folder' unless postResponse.success?

		# Retrieve newly created Folder
		p '>>> Retrieve newly created Folder'
		getFolder = FuelSDK::Folder.new()
		getFolder.authStub = stubObj
		getFolder.props = ["ID", "Client.ID", "ParentFolder.ID", "ParentFolder.CustomerKey", "ParentFolder.ObjectID", "ParentFolder.Name", "ParentFolder.Description", "ParentFolder.ContentType", "ParentFolder.IsActive", "ParentFolder.IsEditable", "ParentFolder.AllowChildren", "Name", "Description", "ContentType", "IsActive", "IsEditable", "AllowChildren", "CreatedDate", "ModifiedDate", "Client.ModifiedBy", "ObjectID", "CustomerKey", "Client.EnterpriseID", "Client.CreatedBy"]
		getFolder.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestFolder}
		getResponse = getFolder.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
    raise 'Failure retrieving Folder' unless getResponse.success?
    raise 'Failure verifying created Folder' if getResponse.results.empty?

		# Update Folder
		p '>>> Update Folder'
		patchFolder = FuelSDK::Folder.new
		patchFolder.authStub = stubObj
		patchFolder.props = {"CustomerKey" => NameOfTestFolder, "Description" => "New Description"}
		patchResponse = patchFolder.patch
		p 'Patch Status: ' + patchResponse.status.to_s
		p 'Code: ' + patchResponse.code.to_s
		p 'Message: ' + patchResponse.message.to_s
		p 'Result Count: ' + patchResponse.results.length.to_s
		p 'Results: ' + patchResponse.results.inspect
    raise 'Failure updating Folder' unless patchResponse.success?

		# Retrieve updated Folder
		p '>>> Retrieve updated Folder'
		getFolder = FuelSDK::Folder.new()
		getFolder.authStub = stubObj
		getFolder.props = ["ID", "Client.ID", "ParentFolder.ID", "ParentFolder.CustomerKey", "ParentFolder.ObjectID", "ParentFolder.Name", "ParentFolder.Description", "ParentFolder.ContentType", "ParentFolder.IsActive", "ParentFolder.IsEditable", "ParentFolder.AllowChildren", "Name", "Description", "ContentType", "IsActive", "IsEditable", "AllowChildren", "CreatedDate", "ModifiedDate", "Client.ModifiedBy", "ObjectID", "CustomerKey", "Client.EnterpriseID", "Client.CreatedBy"]
		getFolder.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestFolder}
		getResponse = getFolder.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
    raise 'Failure retrieving Folder' unless getResponse.success?

		# Delete Folder
		p '>>> Delete Folder'
		deleteFolder = FuelSDK::Folder.new
		deleteFolder.authStub = stubObj
		deleteFolder.props = {"CustomerKey" => NameOfTestFolder, "Name"=>NameOfTestFolder, "Content"=> "<b>Some HTML Content Goes here. NOW WITH NEW CONTENT</b>"}
		deleteResponse = deleteFolder.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Result Count: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.inspect
    raise 'Failure deleting Folder' unless deleteResponse.success?

		# Retrieve Folder to confirm deletion
		p '>>> Retrieve Folder to confirm deletion'
		getFolder = FuelSDK::Folder.new()
		getFolder.authStub = stubObj
		getFolder.props = ["ID"]
		getFolder.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestFolder}
		getResponse = getFolder.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
    raise 'Failure verifying deleted Folder' unless getResponse.success?
    raise 'Failure verifying deleted Folder' unless getResponse.results.empty?
	end
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

