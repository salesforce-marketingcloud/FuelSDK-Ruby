require 'fuelsdk'
require_relative 'sample_helper'

begin
	stubObj = FuelSDK::ET_Client.new auth

	NewListName = "RubySDKList"

	# Create List
	p '>>> Create List'
	postList = FuelSDK::ET_List.new
	postList.authStub = stubObj
	postList.props = {"ListName" => NewListName, "Description" => "This list was created with the RubySDK", "Type" => "Private" }
	postResponse = postList.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect


	# Make sure the list created correctly before
	if postResponse.status then

		newListID = postResponse.results[0][:id]

		# Retrieve newly created List by ID
		p '>>> Retrieve newly created List'
		getList = FuelSDK::ET_List.new()
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

		# Update List
		p '>>> Update List'
		patchSub = FuelSDK::ET_List.new
		patchSub.authStub = stubObj
		patchSub.props = {"ID" => newListID, "Description" => "I updated the description"}
		patchResponse = patchSub.patch
		p 'Patch Status: ' + patchResponse.status.to_s
		p 'Code: ' + patchResponse.code.to_s
		p 'Message: ' + patchResponse.message.to_s
		p 'Result Count: ' + patchResponse.results.length.to_s
		p 'Results: ' + patchResponse.results.inspect

		# Retrieve List that should have description updated
		p '>>> Retrieve List that should have description updated '
		getList = FuelSDK::ET_List.new()
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

		# Delete List
		p '>>> Delete List'
		deleteSub = FuelSDK::ET_List.new()
		deleteSub.authStub = stubObj
		deleteSub.props = {"ID" => newListID}
		deleteResponse = deleteSub.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results Length: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.to_s

		# Retrieve List to confirm deletion
		p '>>> Retrieve List to confirm deletion'
		getList = FuelSDK::ET_List.new()
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
	end

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

