require '../ET_Client.rb'

begin
	stubObj = ET_Client.new(false, false)

	# Retrieve All Folder with GetMoreResults
	p '>>> Retrieve All Folder with GetMoreResults'
	getFolder = ET_Folder.new()
	getFolder.authStub = stubObj
	getFolder.props = ["ID", "Client.ID", "ParentFolder.ID", "ParentFolder.CustomerKey", "ParentFolder.ObjectID", "ParentFolder.Name", "ParentFolder.Description", "ParentFolder.ContentType", "ParentFolder.IsActive", "ParentFolder.IsEditable", "ParentFolder.AllowChildren", "Name", "Description", "ContentType", "IsActive", "IsEditable", "AllowChildren", "CreatedDate", "ModifiedDate", "Client.ModifiedBy", "ObjectID", "CustomerKey", "Client.EnterpriseID", "Client.CreatedBy"]
	getResponse = getFolder.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s

	while getResponse.moreResults do
		p '>>> Continue Retrieve All Folder with GetMoreResults'
		getResponse = getFolder.getMoreResults
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end

	NameOfTestFolder = "RubySDKFolder"

	# Retrieve Specific Folder for Email Folder ParentID
	p '>>> Retrieve Specific Folder for Email Folder ParentID'
	getFolder = ET_Folder.new()
	getFolder.authStub = stubObj
	getFolder.props = ["ID"]
	getFolder.filter = {'LeftOperand' => {'Property' => 'ParentFolder.ID','SimpleOperator' => 'equals','Value' => '0'}, 'LogicalOperator' => 'AND', 'RightOperand' => {'Property' => 'ContentType','SimpleOperator' => 'equals','Value' => 'EMAIL'}}
	getResponse = getFolder.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s

	if getResponse.status then
		ParentIDForEmail = getResponse.results[0][:id]
		p "Parent Folder for Email: #{ParentIDForEmail}"

		# Create Folder
		p '>>> Create Folder'
		postFolder = ET_Folder.new
		postFolder.authStub = stubObj
		postFolder.props = {"CustomerKey" => NameOfTestFolder, "Name" => NameOfTestFolder, "Description" => NameOfTestFolder, "ContentType"=> "EMAIL", "ParentFolder" => {"ID" => ParentIDForEmail}}
		postResponse = postFolder.post
		p 'Post Status: ' + postResponse.status.to_s
		p 'Code: ' + postResponse.code.to_s
		p 'Message: ' + postResponse.message.to_s
		p 'Result Count: ' + postResponse.results.length.to_s
		p 'Results: ' + postResponse.results.inspect

		# Retrieve newly created Folder
		p '>>> Retrieve newly created Folder'
		getFolder = ET_Folder.new()
		getFolder.authStub = stubObj
		getFolder.props = ["ID", "Client.ID", "ParentFolder.ID", "ParentFolder.CustomerKey", "ParentFolder.ObjectID", "ParentFolder.Name", "ParentFolder.Description", "ParentFolder.ContentType", "ParentFolder.IsActive", "ParentFolder.IsEditable", "ParentFolder.AllowChildren", "Name", "Description", "ContentType", "IsActive", "IsEditable", "AllowChildren", "CreatedDate", "ModifiedDate", "Client.ModifiedBy", "ObjectID", "CustomerKey", "Client.EnterpriseID", "Client.CreatedBy"]
		getFolder.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestFolder}
		getResponse = getFolder.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s

		# Update Folder
		p '>>> Update Folder'
		patchFolder = ET_Folder.new
		patchFolder.authStub = stubObj
		patchFolder.props = {"CustomerKey" => NameOfTestFolder, "Description" => "New Description"}
		patchResponse = patchFolder.patch
		p 'Patch Status: ' + patchResponse.status.to_s
		p 'Code: ' + patchResponse.code.to_s
		p 'Message: ' + patchResponse.message.to_s
		p 'Result Count: ' + patchResponse.results.length.to_s
		p 'Results: ' + patchResponse.results.inspect

		# Retrieve updated Folder
		p '>>> Retrieve updated Folder'
		getFolder = ET_Folder.new()
		getFolder.authStub = stubObj
		getFolder.props = ["ID", "Client.ID", "ParentFolder.ID", "ParentFolder.CustomerKey", "ParentFolder.ObjectID", "ParentFolder.Name", "ParentFolder.Description", "ParentFolder.ContentType", "ParentFolder.IsActive", "ParentFolder.IsEditable", "ParentFolder.AllowChildren", "Name", "Description", "ContentType", "IsActive", "IsEditable", "AllowChildren", "CreatedDate", "ModifiedDate", "Client.ModifiedBy", "ObjectID", "CustomerKey", "Client.EnterpriseID", "Client.CreatedBy"]
		getFolder.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestFolder}
		getResponse = getFolder.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s

		# Delete Folder
		p '>>> Delete Folder'
		deleteFolder = ET_Folder.new
		deleteFolder.authStub = stubObj
		deleteFolder.props = {"CustomerKey" => NameOfTestFolder, "Name"=>NameOfTestFolder, "Content"=> "<b>Some HTML Content Goes here. NOW WITH NEW CONTENT</b>"}
		deleteResponse = deleteFolder.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Result Count: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.inspect

		# Retrieve Folder to confirm deletion
		p '>>> Retrieve Folder to confirm deletion'
		getFolder = ET_Folder.new()
		getFolder.authStub = stubObj
		getFolder.props = ["ID"]
		getFolder.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestFolder}
		getResponse = getFolder.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
	end
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

