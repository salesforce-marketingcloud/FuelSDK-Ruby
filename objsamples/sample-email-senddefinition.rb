require '../ET_Client.rb'
require 'securerandom'

begin
	stubObj = ET_Client.new(false, false)	
	
	NewSendDefinitionName = "RubySDKSendDefinition"
	SendableDataExtensionCustomerKey = "62476204-bfd3-de11-95ca-001e0bbae8cc"
	EmailIDForSendDefinition = "3113962"
	ListIDForSendDefinition = "1729515"
	SendClassificationCustomerKey = "2239"	

	p '>>> Create SendDefinition to DataExtension'
	postSendDefinition = ET_Email::SendDefinition.new 
	postSendDefinition.authStub = stubObj
	postSendDefinition.props = {"Name"=>NewSendDefinitionName, "CustomerKey"=>NewSendDefinitionName, "Description"=>"Created with RubySDK", "SendClassification"=>{"CustomerKey"=>SendClassificationCustomerKey},"SendDefinitionList"=>{"CustomObjectID"=> SendableDataExtensionCustomerKey, "DataSourceTypeID"=>"CustomObject"}, "Email" => {"ID"=>EmailIDForSendDefinition}}
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
	postSendDefinition.props = {"Name"=>NewSendDefinitionName, "CustomerKey"=>NewSendDefinitionName, "Description"=>"Created with RubySDK", "SendClassification"=>{"CustomerKey"=>SendClassificationCustomerKey},"SendDefinitionList"=>{"List"=> {"ID"=>ListIDForSendDefinition}, "DataSourceTypeID"=>"List"}, "Email" => {"ID"=>EmailIDForSendDefinition}}
	postResponse = postSendDefinition.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
	
	p '>>> Start SendDefinition'
	sendSendDefinition = ET_Email::SendDefinition.new 
	sendSendDefinition.authStub = stubObj
	sendSendDefinition.props = {"CustomerKey"=>NewSendDefinitionName}
	sendResponse = sendSendDefinition.send
	p 'Start Status: ' + sendResponse.status.to_s
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
	

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

