require '../etClient.rb'
require 'securerandom'

begin
	stubObj = ETClient.new(false, false)
	
	# NOTE: These examples only work in accounts where the SubscriberKey functionality is not enabled
	#       SubscriberKey will need to be included in the props if that feature is enabled	
	
	SubscriberTestEmail = "RubySDKExample@bh.exacttarget.com"	

	# Create Subscriber 
	p '>>> Create Subscriber'
	postSub = ET_Subscriber.new 
	postSub.authStub = stubObj
	postSub.props = {"EmailAddress" => SubscriberTestEmail}		
	postResponse = postSub.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect	
	
	# Retrieve newly created Subscriber
	p '>>> Retrieve newly created Subscriber'
	getSub = ET_Subscriber.new()
	getSub.authStub = stubObj	
	getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
	getSub.filter = {'Property' => 'SubscriberKey','SimpleOperator' => 'equals','Value' => SubscriberTestEmail}
	getResponse = getSub.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s	
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
		
	# Update Subscriber 
	p '>>> Update Subscriber'
	patchSub = ET_Subscriber.new 
	patchSub.authStub = stubObj
	patchSub.props = {"EmailAddress" => SubscriberTestEmail, "Status" => "Unsubscribed"}		
	patchResponse = patchSub.patch
	p 'Patch Status: ' + patchResponse.status.to_s
	p 'Code: ' + patchResponse.code.to_s
	p 'Message: ' + patchResponse.message.to_s
	p 'Result Count: ' + patchResponse.results.length.to_s
	p 'Results: ' + patchResponse.results.inspect	
	
	# Retrieve Subscriber that should have status unsubscribed now
	p '>>> Retrieve Subscriber that should have status unsubscribed now'
	getSub = ET_Subscriber.new()
	getSub.authStub = stubObj	
	getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
	getSub.filter = {'Property' => 'SubscriberKey','SimpleOperator' => 'equals','Value' => SubscriberTestEmail};
	getResponse = getSub.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s	
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s
	
	# Delete Subscriber
	p '>>> Delete Subscriber'
	deleteSub = ET_Subscriber.new()
	deleteSub.authStub = stubObj	
	deleteSub.props = {"EmailAddress" => SubscriberTestEmail}
	deleteResponse = deleteSub.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s	
	p 'Results Length: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.to_s
	
	# Retrieve Subscriber to confirm deletion
	p '>>> Retrieve Subscriber to confirm deletion'
	getSub = ET_Subscriber.new()
	getSub.authStub = stubObj	
	getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
	getSub.filter = {'Property' => 'SubscriberKey','SimpleOperator' => 'equals','Value' => SubscriberTestEmail};
	getResponse = getSub.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s	
	p 'Results Length: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.to_s	
		

=begin
	# Do not run the "Retrieve All Subscribers" request for testing if you have more than 100,000 records in your account as it will take a long time to complete.

	# Retrieve All Subcribers with GetMoreResults
	p '>>> Retrieve All Subcribers with GetMoreResults'
	getSub = ET_Subscriber.new()
	getSub.authStub = stubObj	
	getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
	getResponse = getSub.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	#p 'Results: ' + getResponse.results.to_s

	while getResponse.moreResults do 
		p '>>> Continue Retrieve All Subcribers with GetMoreResults'
		getResponse = getSub.getMoreResults
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end 
=end

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

