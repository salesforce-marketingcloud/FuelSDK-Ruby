require 'fuelsdk'
require_relative 'sample_helper'

begin
	stubObj = FuelSDK::Client.new auth

	# Retrieve All ContentArea with GetMoreResults
	p '>>> Retrieve All ContentArea with GetMoreResults'
	getContent = FuelSDK::ContentArea.new()
	getContent.authStub = stubObj
	getContent.props = ["RowObjectID","ObjectID","ID","CustomerKey","Client.ID","ModifiedDate","CreatedDate","CategoryID","Name","Layout","IsDynamicContent","Content","IsSurvey","IsBlank","Key"]
	getResponse = getContent.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving contentarea' unless getResponse.success?

	while getResponse.more? do
		p '>>> Continue Retrieve All ContentArea with GetMoreResults'
		getResponse = getContent.continue
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end

	NameOfTestContentArea = "RubySDKContentArea"

	# Create ContentArea
	p '>>> Create ContentArea'
	postContent = FuelSDK::ContentArea.new
	postContent.authStub = stubObj
	postContent.props = {"CustomerKey" => NameOfTestContentArea, "Name"=>NameOfTestContentArea, "Content"=> "<b>Some HTML Content Goes here</b>"}
	postResponse = postContent.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
  raise 'Failure creating contentarea' unless postResponse.success?

	# Retrieve newly created ContentArea
	p '>>> Retrieve newly created ContentArea'
	getContent = FuelSDK::ContentArea.new()
	getContent.authStub = stubObj
	getContent.props = ["RowObjectID","ObjectID","ID","CustomerKey","Client.ID","ModifiedDate","CreatedDate","CategoryID","Name","Layout","IsDynamicContent","Content","IsSurvey","IsBlank","Key"]
	getContent.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestContentArea}
	getResponse = getContent.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving contentarea' unless getResponse.success?

	# Update ContentArea
	p '>>> Update ContentArea'
	patchContent = FuelSDK::ContentArea.new
	patchContent.authStub = stubObj
	patchContent.props = {"CustomerKey" => NameOfTestContentArea, "Name"=>NameOfTestContentArea, "Content"=> "<b>Some HTML Content Goes here. NOW WITH NEW CONTENT</b>"}
	patchResponse = patchContent.patch
	p 'Patch Status: ' + patchResponse.status.to_s
	p 'Code: ' + patchResponse.code.to_s
	p 'Message: ' + patchResponse.message.to_s
	p 'Result Count: ' + patchResponse.results.length.to_s
	p 'Results: ' + patchResponse.results.inspect
  raise 'Failure updating contentarea' unless patchResponse.success?

	# Retrieve updated ContentArea
	p '>>> Retrieve updated ContentArea'
	getContent = FuelSDK::ContentArea.new()
	getContent.authStub = stubObj
	getContent.props = ["RowObjectID","ObjectID","ID","CustomerKey","Client.ID","ModifiedDate","CreatedDate","CategoryID","Name","Layout","IsDynamicContent","Content","IsSurvey","IsBlank","Key"]
	getContent.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestContentArea}
	getResponse = getContent.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving contentarea' unless getResponse.success?

	# Delete ContentArea
	p '>>> Delete ContentArea'
	deleteContent = FuelSDK::ContentArea.new
	deleteContent.authStub = stubObj
	deleteContent.props = {"CustomerKey" => NameOfTestContentArea, "Name"=>NameOfTestContentArea, "Content"=> "<b>Some HTML Content Goes here. NOW WITH NEW CONTENT</b>"}
	deleteResponse = deleteContent.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s
	p 'Result Count: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.inspect
  raise 'Failure deleting contentarea' unless deleteResponse.success?

	# Retrieve ContentArea to confirm deletion
	p '>>> Retrieve ContentArea to confirm deletion'
	getContent = FuelSDK::ContentArea.new()
	getContent.authStub = stubObj
	getContent.props = ["RowObjectID","ObjectID","ID","CustomerKey","Client.ID","ModifiedDate","CreatedDate","CategoryID","Name","Layout","IsDynamicContent","Content","IsSurvey","IsBlank","Key"]
	getContent.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestContentArea}
	getResponse = getContent.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving contentarea' unless getResponse.success?

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

