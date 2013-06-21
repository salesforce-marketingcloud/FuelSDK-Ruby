require 'fuelsdk'
require_relative 'sample_helper'

begin
	stubObj = FuelSDK::Client.new auth

	# Retrieve All Email with GetMoreResults
	p '>>> Retrieve All Email with GetMoreResults'
	getHTMLBody = FuelSDK::Email.new()
	getHTMLBody.authStub = stubObj
	getHTMLBody.props = ["ID","PartnerKey","CreatedDate","ModifiedDate","Client.ID","Name","Folder","CategoryID","HTMLBody","TextBody","Subject","IsActive","IsHTMLPaste","ClonedFromID","Status","EmailType","CharacterSet","HasDynamicSubjectLine","ContentCheckStatus","Client.PartnerClientKey","ContentAreas","CustomerKey"]
	getResponse = getHTMLBody.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving email' unless getResponse.success?

	while getResponse.more? do
		p '>>> Continue Retrieve All Email with GetMoreResults'
		getResponse = getHTMLBody.continue
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end

	NameOfTestEmail = "RubySDKEmail"

	# Create Email
	p '>>> Create Email'
	postHTMLBody = FuelSDK::Email.new
	postHTMLBody.authStub = stubObj
	postHTMLBody.props = {"CustomerKey" => NameOfTestEmail, "Name"=>NameOfTestEmail, "Subject" => "Created Using the RubySDK", "HTMLBody"=> "<b>Some HTML Goes here</b>"}
	postResponse = postHTMLBody.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
  raise 'Failure creating email' unless postResponse.success?

	# Retrieve newly created Email
	p '>>> Retrieve newly created Email'
	getHTMLBody = FuelSDK::Email.new()
	getHTMLBody.authStub = stubObj
	getHTMLBody.props = ["ID","PartnerKey","CreatedDate","ModifiedDate","Client.ID","Name","Folder","CategoryID","HTMLBody","TextBody","Subject","IsActive","IsHTMLPaste","ClonedFromID","Status","EmailType","CharacterSet","HasDynamicSubjectLine","ContentCheckStatus","Client.PartnerClientKey","ContentAreas","CustomerKey"]
	getHTMLBody.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestEmail}
	getResponse = getHTMLBody.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving email' unless getResponse.success?

	# Update Email
	p '>>> Update Email'
	patchHTMLBody = FuelSDK::Email.new
	patchHTMLBody.authStub = stubObj
	patchHTMLBody.props = {"CustomerKey" => NameOfTestEmail, "Name"=>NameOfTestEmail,  "HTMLBody"=> "<b>Some HTML HTMLBody Goes here. NOW WITH NEW HTMLBody</b>"}
	patchResponse = patchHTMLBody.patch
	p 'Patch Status: ' + patchResponse.status.to_s
	p 'Code: ' + patchResponse.code.to_s
	p 'Message: ' + patchResponse.message.to_s
	p 'Result Count: ' + patchResponse.results.length.to_s
	p 'Results: ' + patchResponse.results.inspect
  raise 'Failure updating email' unless patchResponse.success?

	# Retrieve updated Email
	p '>>> Retrieve updated Email'
	getHTMLBody = FuelSDK::Email.new()
	getHTMLBody.authStub = stubObj
	getHTMLBody.props = ["ID","PartnerKey","CreatedDate","ModifiedDate","Client.ID","Name","Folder","CategoryID","HTMLBody","TextBody","Subject","IsActive","IsHTMLPaste","ClonedFromID","Status","EmailType","CharacterSet","HasDynamicSubjectLine","ContentCheckStatus","Client.PartnerClientKey","ContentAreas","CustomerKey"]
	getHTMLBody.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestEmail}
	getResponse = getHTMLBody.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving email' unless getResponse.success?

	# Delete Email
	p '>>> Delete Email'
	deleteHTMLBody = FuelSDK::Email.new
	deleteHTMLBody.authStub = stubObj
	deleteHTMLBody.props = {"CustomerKey" => NameOfTestEmail, "Name"=>NameOfTestEmail, "HTMLBody"=> "<b>Some HTML HTMLBody Goes here. NOW WITH NEW HTMLBody</b>"}
	deleteResponse = deleteHTMLBody.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s
	p 'Result Count: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.inspect
  raise 'Failure deleteing email' unless deleteResponse.success?

	# Retrieve Email to confirm deletion
	p '>>> Retrieve Email to confirm deletion'
	getHTMLBody = FuelSDK::Email.new()
	getHTMLBody.authStub = stubObj
	getHTMLBody.props = ["ID","PartnerKey","CreatedDate","ModifiedDate","Client.ID","Name","Folder","CategoryID","HTMLBody","TextBody","Subject","IsActive","IsHTMLPaste","ClonedFromID","Status","EmailType","CharacterSet","HasDynamicSubjectLine","ContentCheckStatus","Client.PartnerClientKey","ContentAreas","CustomerKey"]
	getHTMLBody.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => NameOfTestEmail}
	getResponse = getHTMLBody.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving email' unless getResponse.success?

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

