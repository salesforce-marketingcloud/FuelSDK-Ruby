require 'fuelsdk'
require_relative 'sample_helper'

begin
	stubObj = FuelSDK::Client.new auth

	NewListName = "RubySDKList"

	# Create List
	p '>>> Create List'
	postList = FuelSDK::List.new
	postList.authStub = stubObj
	postList.props = {"ListName" => NewListName, "Description" => "This list was created with the RubySDK", "Type" => "Private" }
	#postList.folder_id = 1083760
	postResponse = postList.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
  raise 'Failure creating list' unless postResponse.success?

	# Make sure the list created correctly before
	if postResponse.success? then

		newListID = postResponse.results[0][:new_id]

		# Retrieve newly created List by ID
		p '>>> Retrieve newly created List'
		getList = FuelSDK::List.new()
		getList.authStub = stubObj
		getList.props = ["ID","PartnerKey","CreatedDate","ModifiedDate","Client.ID","Client.PartnerClientKey","ListName","Description","Category","Type","CustomerKey","ListClassification","AutomatedEmail.ID"]
		getList.filter = {'Property' =>  'ID','SimpleOperator' => 'equals','Value' => newListID}
		getResponse = getList.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
    raise 'Failure retrieving list' unless getResponse.success?

		# Update List
		p '>>> Update List'
		patchSub = FuelSDK::List.new
		patchSub.authStub = stubObj
		patchSub.props = {"ID" => newListID, "Description" => "I updated the description"}
		patchResponse = patchSub.patch
		p 'Patch Status: ' + patchResponse.status.to_s
		p 'Code: ' + patchResponse.code.to_s
		p 'Message: ' + patchResponse.message.to_s
		p 'Result Count: ' + patchResponse.results.length.to_s
		p 'Results: ' + patchResponse.results.inspect
    raise 'Failure updating list' unless patchResponse.success?
    raise 'Failure updating list' unless patchResponse.results.first[:object][:description] == "I updated the description"

		# Retrieve List that should have description updated
		p '>>> Retrieve List that should have description updated '
		getList = FuelSDK::List.new()
		getList.authStub = stubObj
		getList.props = ["ID","PartnerKey","CreatedDate","ModifiedDate","Client.ID","Client.PartnerClientKey","ListName","Description","Category","Type","CustomerKey","ListClassification","AutomatedEmail.ID"]
		getList.filter = {'Property' => 'ID','SimpleOperator' => 'equals','Value' => newListID}
		getResponse = getList.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
    raise 'Failure retrieving list' unless getResponse.success?

		# Delete List
		p '>>> Delete List'
		deleteSub = FuelSDK::List.new()
		deleteSub.authStub = stubObj
		deleteSub.props = {"ID" => newListID}
		deleteResponse = deleteSub.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results Length: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.to_s
    raise 'Failure deleting list' unless deleteResponse.success?

		# Retrieve List to confirm deletion
		p '>>> Retrieve List to confirm deletion'
		getList = FuelSDK::List.new()
		getList.authStub = stubObj
		getList.props = ["ID","PartnerKey","CreatedDate","ModifiedDate","Client.ID","Client.PartnerClientKey","ListName","Description","Category","Type","CustomerKey","ListClassification","AutomatedEmail.ID"]
		getList.filter = {'Property' => 'ID','SimpleOperator' => 'equals','Value' => newListID}
		getResponse = getList.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
    raise 'Failure retrieving list' unless getResponse.success?
	end

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

