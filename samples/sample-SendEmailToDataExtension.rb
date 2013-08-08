require 'fuelsdk'
require_relative 'sample_helper'

begin
	myclient = FuelSDK::Client.new auth
	
	EmailIDForSendDefinition = "3113962"
	SendClassificationCustomerKey = "2239"
	SendableDataExtensionCustomerKey = "F6F3871A-D124-499B-BBF5-3EFC0E827A51"

	# Call SendEmailToDataExtension
	response = myclient.SendEmailToDataExtension(EmailIDForSendDefinition, SendableDataExtensionCustomerKey,SendClassificationCustomerKey)
	p 'Response Status: ' + response.status.to_s
	p 'Code: ' + response.code.to_s
	p 'Message: ' + response.message.to_s	
	p 'Results Length: ' + response.results.length.to_s
	p 'Results: ' + response.results.to_s

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

