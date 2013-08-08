require 'fuelsdk'
require_relative 'sample_helper'

begin
	myclient = FuelSDK::Client.new auth
	
	EmailIDForSendDefinition = "3113962"
	ListIDForSendDefinition = "1729515"
	SendClassificationCustomerKey = "2239"
	
	# Call SendEmailToList
	response = myclient.SendEmailToList(EmailIDForSendDefinition, ListIDForSendDefinition,SendClassificationCustomerKey)
	p 'Response Status: ' + response.status.to_s
	p 'Code: ' + response.code.to_s
	p 'Message: ' + response.message.to_s	
	p 'Results Length: ' + response.results.length.to_s
	p 'Results: ' + response.results.to_s
	
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

