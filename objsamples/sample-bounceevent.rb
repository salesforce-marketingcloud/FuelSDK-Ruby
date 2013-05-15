require '../ET_Client.rb'

begin
	stubObj = ET_Client.new(false, false)
		
	## Modify the date below to reduce the number of results returned from the request
	## Setting this too far in the past could result in a very large response size
	retrieveDate = '2011-01-15T13:00:00.000'

	p '>>> Retrieve Filtered BounceEvents with GetMoreResults'
	getBounceEvent = ET_BounceEvent.new()
	getBounceEvent.authStub = stubObj	
	getBounceEvent.props = ["SendID","SubscriberKey","EventDate","Client.ID","EventType","BatchID","TriggeredSendDefinitionObjectID","PartnerKey"]
	getBounceEvent.filter = {'Property' => 'EventDate','SimpleOperator' => 'greaterThan','DateValue' => retrieveDate}
	getResponse = getBounceEvent.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	# Since this could potentially return a large number of results, we do not want to print the results
	# p 'Results: ' + getResponse.results.to_s

	while getResponse.moreResults do 
		p '>>> Continue Retrieve Filtered BounceEvents with GetMoreResults'
		getResponse = getBounceEvent.getMoreResults
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end 
	
	p '>>> Retrieve Filtered BounceEvents with GetSinceLastBatch set to false'
	getBounceEvent = ET_BounceEvent.new()
	getBounceEvent.authStub = stubObj	
	getBounceEvent.props = ["SendID","SubscriberKey","EventDate","Client.ID","EventType","BatchID","TriggeredSendDefinitionObjectID","PartnerKey"]
	getBounceEvent.filter = {'Property' => 'EventDate','SimpleOperator' => 'greaterThan','DateValue' => retrieveDate}
	getBounceEvent.getSinceLastBatch = false
	getResponse = getBounceEvent.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	
	while getResponse.moreResults do 
		p '>>> Continue Retrieve Filtered BounceEvents with GetSinceLastBatch set to false'
		getResponse = getBounceEvent.getMoreResults
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.moreResults.to_s
		p 'RequestID: ' + getResponse.request_id.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
	end 
	
	#  The following request could potentially bring back large amounts of data if run against a production account	
=begin 
	p '>>> Retrieve All BounceEvents with GetMoreResults'
	getBounceEvent = ET_BounceEvent.new()
	getBounceEvent.authStub = stubObj	
	getBounceEvent.props = ["SendID","SubscriberKey","EventDate","Client.ID","EventType","BatchID","TriggeredSendDefinitionObjectID","PartnerKey"]	
	getResponse = getBounceEvent.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.moreResults.to_s
	p 'RequestID: ' + getResponse.request_id.to_s
	p 'Results Length: ' + getResponse.results.length.to_s
	# Since this could potentially return a large number of results, we do not want to print the results
	#p 'Results: ' + getResponse.results.to_s
	
	while getResponse.moreResults do 
		p '>>> Continue Retrieve All BounceEvents with GetMoreResults'
		getResponse = getBounceEvent.getMoreResults
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

