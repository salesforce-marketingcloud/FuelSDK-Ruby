require '../ET_Client.rb'
require 'securerandom'

begin
	stubObj = ET_Client.new(false, false)	
	
	NewSendDefinitionName = "RubySDKSendDefinition"
	SendableDataExtensionCustomerKey = "F6F3871A-D124-499B-BBF5-3EFC0E827A51"
	EmailIDForSendDefinition = "3113962"
	ListIDForSendDefinition = "1729515"
	SendClassificationCustomerKey = "2239"
	
	p '>>> Retrieve Send Definition Details'
	getSendDefinition = ET_Email::SendDefinition.new 
	getSendDefinition.authStub = stubObj
	getSendDefinition.props = ['Client.ID', 'CreatedDate','ModifiedDate','ObjectID','CustomerKey','Name','CategoryID','Description','SendClassification.CustomerKey','SenderProfile.CustomerKey','SenderProfile.FromName','SenderProfile.FromAddress','DeliveryProfile.CustomerKey','DeliveryProfile.SourceAddressType','DeliveryProfile.PrivateIP','DeliveryProfile.DomainType','DeliveryProfile.PrivateDomain','DeliveryProfile.HeaderSalutationSource','DeliveryProfile.FooterSalutationSource','SuppressTracking','IsSendLogging','Email.ID','BccEmail','AutoBccEmail','TestEmailAddr','EmailSubject','DynamicEmailSubject','IsMultipart','IsWrapped','SendLimit','SendWindowOpen','SendWindowClose','DeduplicateByEmail','ExclusionFilter','Additional']
	getResponse = getSendDefinition.get
	p 'Post Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'Result Count: ' + getResponse.results.length.to_s
	
=begin
	p '>>> Create SendDefinition to DataExtension'
	postSendDefinition = ET_Email::SendDefinition.new 
	postSendDefinition.authStub = stubObj
	postSendDefinition.props = {"Name"=>NewSendDefinitionName}
	postSendDefinition.props["CustomerKey"] = NewSendDefinitionName
	postSendDefinition.props["Description"]  = "Created with RubySDK"
	postSendDefinition.props["SendClassification"] = {"CustomerKey"=>SendClassificationCustomerKey}
	postSendDefinition.props["SendDefinitionList"] = {"CustomerKey"=> SendableDataExtensionCustomerKey, "DataSourceTypeID"=>"CustomObject"}
	postSendDefinition.props["Email"] = {"ID"=>EmailIDForSendDefinition}
	postResponse = postSendDefinition.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect

	p '>>> Delete SendDefinition'
	deleteSendDefinition = ET_Email::SendDefinition.new()
	deleteSendDefinition.authStub = stubObj
	deleteSendDefinition.props = {"CustomerKey" => NewSendDefinitionName}
	deleteResponse = deleteSendDefinition.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s	
	p 'Results Length: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.to_s	
	
	p '>>> Create SendDefinition to List'
	postSendDefinition = ET_Email::SendDefinition.new 
	postSendDefinition.authStub = stubObj
	postSendDefinition.props = {"Name"=>NewSendDefinitionName}
	postSendDefinition.props["CustomerKey"] = NewSendDefinitionName
	postSendDefinition.props["Description"] = "Created with RubySDK"
	postSendDefinition.props["SendClassification"] = {"CustomerKey"=>SendClassificationCustomerKey}
	postSendDefinition.props["SendDefinitionList"] = {"List"=> {"ID"=>ListIDForSendDefinition}, "DataSourceTypeID"=>"List"}
	postSendDefinition.props["Email"] = {"ID"=>EmailIDForSendDefinition}
	postResponse = postSendDefinition.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
	
	p '>>> Send SendDefinition'
	sendSendDefinition = ET_Email::SendDefinition.new 
	sendSendDefinition.authStub = stubObj
	sendSendDefinition.props = {"CustomerKey"=>NewSendDefinitionName}
	sendResponse = sendSendDefinition.send
	p 'Send Status: ' + sendResponse.status.to_s
	p 'Code: ' + sendResponse.code.to_s
	p 'Message: ' + sendResponse.message.to_s
	p 'Result Count: ' + sendResponse.results.length.to_s
	p 'Results: ' + sendResponse.results.inspect
	
	p '>>> Check Status using the same instance of ET_Email::SendDefinition as used with start method'
	emailStatus = ""
	while emailStatus != "Canceled" && emailStatus != "Complete" do
		p '>>> Checking status in loop'
		# Wait a bit before checking the status to give it time to process
		sleep 30
		statusResponse = sendSendDefinition.status
		p 'Status Status: ' + statusResponse.status.to_s
		p 'Code: ' + statusResponse.code.to_s
		p 'Message: ' + statusResponse.message.to_s
		p 'Result Count: ' + statusResponse.results.length.to_s
		p 'Results: ' + statusResponse.results.inspect
		emailStatus = statusResponse.results[0][:status]
	end

	p '>>> Delete SendDefinition'
	deleteSendDefinition = ET_Email::SendDefinition.new()
	deleteSendDefinition.authStub = stubObj
	deleteSendDefinition.props = {"CustomerKey" => NewSendDefinitionName}
	deleteResponse = deleteSendDefinition.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s	
	p 'Results Length: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.to_s
	
=end
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

