require 'fuelsdk'
require_relative 'sample_helper'

begin
	stubObj = FuelSDK::Client.new auth

	# NOTE: These examples only work in accounts where the SubscriberKey functionality is not enabled
	#       SubscriberKey will need to be included in the props if that feature is enabled

	NewListName = "RubySDKListSubscriber"
	SubscriberTestEmail = "RubySDKListSubscriber@bh.exacttarget.com"

	# Create List
	p '>>> Create List'
	postList = FuelSDK::List.new
	postList.authStub = stubObj
	postList.props = {"ListName" => NewListName, "Description" => "This list was created with the RubySDK", "Type" => "Private" }
	postResponse = postList.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect

  raise 'Failure posting list' unless postResponse.success?


	# Make sure the list created correctly before
	if postResponse.success? then

		newListID = postResponse.results[0][:new_id]

		# Create Subscriber On List
		p '>>> Create Subscriber On List'
		postSub = FuelSDK::Subscriber.new
		postSub.authStub = stubObj
		postSub.props = {"EmailAddress" => SubscriberTestEmail, "Lists" =>[{"ID" => newListID}]}
		postResponse = postSub.post
		p 'Post Status: ' + postResponse.status.to_s
		p 'Code: ' + postResponse.code.to_s
		p 'Message: ' + postResponse.message.to_s
		p 'Result Count: ' + postResponse.results.length.to_s
		p 'Results: ' + postResponse.results.inspect

		if postResponse.success? == false then
			# If the subscriber already exists in the account then we need to do an update.
			# Update Subscriber On List
			if postResponse.results[0][:error_code] == "12014" then
				# Update Subscriber to add to List
				p '>>> Update Subscriber to add to List'
				patchSub = FuelSDK::Subscriber.new
				patchSub.authStub = stubObj
				patchSub.props = {"EmailAddress" => SubscriberTestEmail, "Lists" =>[{"ID" => newListID}]}
				patchResponse = patchSub.patch
				p 'Patch Status: ' + patchResponse.status.to_s
				p 'Code: ' + patchResponse.code.to_s
				p 'Message: ' + patchResponse.message.to_s
				p 'Result Count: ' + patchResponse.results.length.to_s
				p 'Results: ' + patchResponse.results.inspect
        raise 'Failure updating subscriber' unless patchResponse.success?
			end
		end


		# Retrieve all Subscribers on the List
		p '>>> Retrieve all Subscribers on the List'
		getListSubs = FuelSDK::List::Subscriber.new
		getListSubs.authStub = stubObj
		getListSubs.props = ["ObjectID","SubscriberKey","CreatedDate","Client.ID","Client.PartnerClientKey","ListID","Status"]
		getListSubs.filter = {'Property' => 'ListID','SimpleOperator' => 'equals','Value' => newListID}
		getResponse = getListSubs.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results Length: ' + getResponse.results.length.to_s
		p 'Results: ' + getResponse.results.to_s
    raise 'Failure retrieving subscirbers on list' unless getResponse.success?

		# Delete List
		p '>>> Delete List'
		deleteSub = FuelSDK::List.new()
		deleteSub.authStub = stubObj
		deleteSub.props = {"ID" => newListID}
		deleteResponse = deleteSub.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results Length: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.to_s
    raise 'Failure deleting list' unless deleteResponse.success?
	end
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

