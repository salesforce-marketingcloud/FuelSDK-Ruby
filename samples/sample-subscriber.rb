require 'fuelsdk'
require_relative 'sample_helper' # contains auth with credentials

begin
  stubObj = FuelSDK::Client.new auth

  # NOTE: These examples only work in accounts where the SubscriberKey functionality is not enabled
  #       SubscriberKey will need to be included in the props if that feature is enabled

  SubscriberTestEmail = "RubySDKExample@jb.kevy.com"

  # Create Subscriber
  p '>>> Create Subscriber'
  postSub = FuelSDK::Subscriber.new
  postSub.authStub = stubObj
  postSub.props = {"EmailAddress" => SubscriberTestEmail}
  p '>>> Posting'
  postResponse = postSub.post
  p "Post Status: #{postResponse.success? ? 'Success' : 'Failure'}"
  p 'Code: ' + postResponse.code.to_s
  p 'Message: ' + postResponse.message.to_s
  p 'Result Count: ' + postResponse.results.length.to_s
  p 'Results: ' + postResponse.results.inspect

  raise 'Failure creating subscriber' unless postResponse.success?

  # Retrieve newly created Subscriber
  p '>>> Retrieve newly created Subscriber'
  getSub = FuelSDK::Subscriber.new()
  getSub.authStub = stubObj
  getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
  getSub.filter = {'Property' => 'SubscriberKey', 'SimpleOperator' => 'equals', 'Value' => SubscriberTestEmail}
  getResponse = getSub.get
  p "Retrieve Status: #{getResponse.success? ? 'Success' : 'Failure'}"
  p 'Code: ' + getResponse.code.to_s
  p 'Message: ' + getResponse.message.to_s
  p 'MoreResults: ' + getResponse.more?.to_s
  p 'Results Length: ' + getResponse.results.length.to_s
  p 'Results: ' + getResponse.results.to_s

  raise 'Failure retrieving subscriber' unless getResponse.success?

  # Update Subscriber
  p '>>> Update Subscriber'
  patchSub = FuelSDK::Subscriber.new
  patchSub.authStub = stubObj
  patchSub.props = {"EmailAddress" => SubscriberTestEmail, "Status" => "Unsubscribed"}
  patchResponse = patchSub.patch
  p 'Patch Status: ' + patchResponse.status.to_s
  p 'Code: ' + patchResponse.code.to_s
  p 'Message: ' + patchResponse.message.to_s
  p 'Result Count: ' + patchResponse.results.length.to_s
  p 'Results: ' + patchResponse.results.inspect

  raise 'Failure updating subscriber' unless patchResponse.success?

  # Retrieve Subscriber that should have status unsubscribed now
  p '>>> Retrieve Subscriber that should have status unsubscribed now'
  getSub = FuelSDK::Subscriber.new()
  getSub.authStub = stubObj
  getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
  getSub.filter = {'Property' => 'SubscriberKey','SimpleOperator' => 'equals','Value' => SubscriberTestEmail};
  getResponse = getSub.get
  p 'Retrieve Status: ' + getResponse.status.to_s
  p 'Code: ' + getResponse.code.to_s
  p 'Message: ' + getResponse.message.to_s
  p 'MoreResults: ' + getResponse.more?.to_s
  p 'Results Length: ' + getResponse.results.length.to_s
  p 'Results: ' + getResponse.results.to_s

  raise 'Failure retrieving subscriber' unless getResponse.success?

  # Delete Subscriber
  p '>>> Delete Subscriber'
  deleteSub = FuelSDK::Subscriber.new()
  deleteSub.authStub = stubObj
  deleteSub.props = {"EmailAddress" => SubscriberTestEmail}
  deleteResponse = deleteSub.delete
  p 'Delete Status: ' + deleteResponse.status.to_s
  p 'Code: ' + deleteResponse.code.to_s
  p 'Message: ' + deleteResponse.message.to_s
  p 'Results Length: ' + deleteResponse.results.length.to_s
  p 'Results: ' + deleteResponse.results.to_s

  raise 'Failure deleting subscriber' unless deleteResponse.success?

  # Retrieve Subscriber to confirm deletion
  p '>>> Retrieve Subscriber to confirm deletion'
  getSub = FuelSDK::Subscriber.new()
  getSub.authStub = stubObj
  getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
  getSub.filter = {'Property' => 'SubscriberKey','SimpleOperator' => 'equals','Value' => SubscriberTestEmail};
  getResponse = getSub.get
  p 'Retrieve Status: ' + getResponse.status.to_s
  p 'Code: ' + getResponse.code.to_s
  p 'Message: ' + getResponse.message.to_s
  p 'MoreResults: ' + getResponse.more?.to_s
  p 'Results Length: ' + getResponse.results.length.to_s
  p 'Results: ' + getResponse.results.to_s

  raise 'Failure retrieving subscriber' unless getResponse.success?

=begin
  # Do not run the "Retrieve All Subscribers" request for testing if you have more than 100,000 records in your account as it will take a long time to complete.

  # Retrieve All Subcribers with GetMoreResults
  p '>>> Retrieve All Subcribers with GetMoreResults'
  getSub = FuelSDK::Subscriber.new()
  getSub.authStub = stubObj
  getSub.props = ["SubscriberKey", "EmailAddress", "Status"]
  getResponse = getSub.get
  p 'Retrieve Status: ' + getResponse.status.to_s
  p 'Code: ' + getResponse.code.to_s
  p 'Message: ' + getResponse.message.to_s
  p 'MoreResults: ' + getResponse.more?.to_s
  p 'RequestID: ' + getResponse.request_id.to_s
  p 'Results Length: ' + getResponse.results.length.to_s
  #p 'Results: ' + getResponse.results.to_s

  while getResponse.more? do
    p '>>> Continue Retrieve All Subcribers with GetMoreResults'
    getResponse.continue
    p 'Retrieve Status: ' + getResponse.status.to_s
    p 'Code: ' + getResponse.code.to_s
    p 'Message: ' + getResponse.message.to_s
    p 'MoreResults: ' + getResponse.more?.to_s
    p 'RequestID: ' + getResponse.request_id.to_s
    p 'Results Length: ' + getResponse.results.length.to_s
  end
=end

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace
end

