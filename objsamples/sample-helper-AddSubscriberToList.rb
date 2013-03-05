require '../etClient.rb'

begin
	stubObj = ETClient.new(false, false)
	
	NewListName = "RubySDKList"

	## Example using AddSubscriberToList() method
	## Typically this method will be used with a pre-existing list but for testing purposes one is being created.
	
	# Create List 
	p '>>> Create List'
	postList = ET_List.new 
	postList.authStub = stubObj
	postList.props = {"ListName" => NewListName, "Description" => "This list was created with the RubySDK", "Type" => "Private" }		
	postResponse = postList.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect	
	
	if postResponse.status then 
		
		newListID = postResponse.results[0][:new_id]
		# Adding Subscriber To a List
		p '>>> Add Subscriber To a List'
		AddSubResponse = stubObj.AddSubscriberToList("AddSubTesting@bh.exacttarget.com", [newListID])	
		p 'AddSubResponse Status: ' + AddSubResponse.status.to_s
		p 'Code: ' + AddSubResponse.code.to_s
		p 'Message: ' + AddSubResponse.message.to_s
		p 'Result Count: ' + AddSubResponse.results.length.to_s
		p 'Results: ' + AddSubResponse.results.inspect
				
		# Delete List
		p '>>> Delete List'
		deleteSub = ET_List.new()
		deleteSub.authStub = stubObj	
		deleteSub.props = {"ID" => newListID}
		deleteResponse = deleteSub.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s	
		p 'Results Length: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.to_s					
	end

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

