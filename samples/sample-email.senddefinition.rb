require 'fuelsdk'
require_relative 'sample_helper'

begin
	stubObj = FuelSDK::Client.new auth
	
	NewSendDefinitionName = "PHPSDKSendDefinition";
	SendableDataExtensionCustomerKey = "F6F3871A-D124-499B-BBF5-3EFC0E827A51";
	EmailIDForSendDefinition = "3113962";
	ListIDForSendDefinition = "1729515";
	SendClassificationCustomerKey = "2239";

	# Retrieve All Email::SendDefinition with GetMoreResults
	p '>>> Retrieve All Email.SendDefinition with GetMoreResults'
	sendDef = FuelSDK::Email::SendDefinition.new()
	sendDef.authStub = stubObj
	sendDef.props = ["Client.ID", "CreatedDate","ModifiedDate","ObjectID","CustomerKey","Name","CategoryID","Description","SendClassification.CustomerKey","SenderProfile.CustomerKey","SenderProfile.FromName","SenderProfile.FromAddress","DeliveryProfile.CustomerKey","DeliveryProfile.SourceAddressType","DeliveryProfile.PrivateIP","DeliveryProfile.DomainType","DeliveryProfile.PrivateDomain","DeliveryProfile.HeaderSalutationSource","DeliveryProfile.FooterSalutationSource","SuppressTracking","IsSendLogging","Email.ID","BccEmail","AutoBccEmail","TestEmailAddr","EmailSubject","DynamicEmailSubject","IsMultipart","IsWrapped","SendLimit","SendWindowOpen","SendWindowClose","DeduplicateByEmail","ExclusionFilter","Additional"]
	getResponse = sendDef.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s
  raise 'Failure retrieving SendDefinition' unless getResponse.success?
  

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

	p '>>> Create New Email.SendDefinition to DataExtension'
	postSendDefinition = FuelSDK::Email::SendDefinition.new()
	postSendDefinition.authStub = stubObj	
	postSendDefinition.props = {}
	postSendDefinition.props["Name"] = NewSendDefinitionName
	postSendDefinition.props["CustomerKey"] = NewSendDefinitionName
	postSendDefinition.props["Description"]  = "Created with PHPSDK"
	postSendDefinition.props["SendClassification"] = {"CustomerKey"=>SendClassificationCustomerKey}
	postSendDefinition.props["SendDefinitionList"] = {"CustomerKey"=> SendableDataExtensionCustomerKey, "DataSourceTypeID"=>"CustomObject"}
	postSendDefinition.props["Email"] = {"ID"=>EmailIDForSendDefinition}
	postResponse = postSendDefinition.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'MoreResults: ' + postResponse.more?.to_s
	p 'Results Length: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.to_s
	#raise 'Failure Creating SendDefinition' unless postResponse.success?

	p '>>> Delete SendDefinition to DataExtension'
	deleteSendDefinition = FuelSDK::Email::SendDefinition.new()
	deleteSendDefinition.authStub = stubObj	
	deleteSendDefinition.props = {"CustomerKey"=> NewSendDefinitionName}
	deleteResponse = deleteSendDefinition.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s
	p 'MoreResults: ' + deleteResponse.more?.to_s
	p 'Results Length: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.to_s
	#raise 'Failure Deleting SendDefinition' unless deleteResponse.success?
	
	
	p '>>> Create New Email.SendDefinition to List'
	postSendDefinition = FuelSDK::Email::SendDefinition.new()
	postSendDefinition.authStub = stubObj	
	postSendDefinition.props = {"Name"=>NewSendDefinitionName}
	postSendDefinition.props["CustomerKey"] = NewSendDefinitionName
	postSendDefinition.props["Description"]  = "Created with PHPSDK"
	postSendDefinition.props["SendClassification"] = {"CustomerKey"=>SendClassificationCustomerKey}
	postSendDefinition.props["SendDefinitionList"] = {"List"=> {"ID"=>ListIDForSendDefinition}, "DataSourceTypeID"=>"List"}
	postSendDefinition.props["Email"] = {"ID"=>EmailIDForSendDefinition}
	postResponse = postSendDefinition.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'MoreResults: ' + postResponse.more?.to_s
	p 'Results Length: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.to_s
	raise 'Failure Creating SendDefinition' unless postResponse.success?
	
	p '>>> Send SendDefinition to List'
	sendSendDefinition = FuelSDK::Email::SendDefinition.new()
	sendSendDefinition.authStub = stubObj	
	sendSendDefinition.props = {"CustomerKey"=> NewSendDefinitionName}
	sendResponse = sendSendDefinition.send
	p 'Send Status: ' + sendResponse.status.to_s
	p 'Code: ' + sendResponse.code.to_s
	p 'Message: ' + sendResponse.message.to_s
	p 'MoreResults: ' + sendResponse.more?.to_s
	p 'Results Length: ' + sendResponse.results.length.to_s
	p 'Results: ' + sendResponse.results.to_s
	raise 'Failure Sending SendDefinition' unless sendResponse.success?
	
	emailStatus = ""
	while emailStatus != "Canceled" && emailStatus != "Complete" do
		p '>>> Checking status in loop'
		# Wait a bit before checking the status to give it time to process
		sleep 10
		statusResponse = sendSendDefinition.status
		p 'Status Status: ' + statusResponse.status.to_s
		p 'Code: ' + statusResponse.code.to_s
		p 'Message: ' + statusResponse.message.to_s
		p 'Result Count: ' + statusResponse.results.length.to_s
		p 'Results: ' + statusResponse.results.inspect
		emailStatus = statusResponse.results[0][:status]
	end
	
	p '>>> Delete SendDefinition to List'
	deleteSendDefinition = FuelSDK::Email::SendDefinition.new()
	deleteSendDefinition.authStub = stubObj	
	deleteSendDefinition.props = {"CustomerKey"=> NewSendDefinitionName}
	deleteResponse = deleteSendDefinition.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s
	p 'MoreResults: ' + deleteResponse.more?.to_s
	p 'Results Length: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.to_s
	raise 'Failure Deleting SendDefinition' unless deleteResponse.success?
	
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

