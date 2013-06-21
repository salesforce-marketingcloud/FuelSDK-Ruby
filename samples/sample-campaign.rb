require 'fuelsdk'
require_relative 'sample_helper'


begin
	stubObj = FuelSDK::Client.new auth

	# Create List
	p '>>> Create List'
	postList = FuelSDK::List.new
	postList.authStub = stubObj
	postList.props = {"ListName" => 'RubyAssetList', "Description" => "This list was created with the RubySDK", "Type" => "Private" }
	postResponse = postList.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect

  raise 'Failure creating list for asset' unless postResponse.success?

	# In order for this sample to run, it needs to have an asset that it can associate the campaign to
	ExampleAssetType = "LIST"
	ExampleAssetItemID = postResponse.results[0][:new_id]

	# Retrieve all Campaigns
	p '>>> Retrieve all Campaigns'
	getCamp = FuelSDK::Campaign.new
	getCamp.authStub = stubObj
	getResponse = getCamp.get
	p 'Retrieve Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'MoreResults: ' + getResponse.more?.to_s
	p "Results: #{getResponse.results}"
	p 'Results(Items) Length: ' + getResponse.results['items'].length.to_s
	p '-----------------------------'

  raise 'Failure retrieving campaigns' unless getResponse.success?

	while getResponse.more? do
		p '>>> Continue Retrieve all Campaigns with GetMoreResults'
		getResponse = getCamp.continue
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'MoreResults: ' + getResponse.more?.to_s
		p 'Results(Items) Length: ' + getResponse.results['items'].length.to_s
	end

	# Create a new Campaign
	p '>>> Create a new Campaign'
	postCamp = FuelSDK::Campaign.new
	postCamp.authStub = stubObj
	postCamp.props = {"name" => "RubySDKCreatedForTest1", "description"=> "RubySDKCreatedForTest", "color"=>"FF9933", "favorite"=>"false"}
	postResponse = postCamp.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.to_json
	p '-----------------------------'

  raise 'Failure creating campaign' unless postResponse.success?

	IDOfpostCampaign = postResponse.results['id']

		# Retrieve the new Campaign
		p '>>> Retrieve the new Campaign'
		getCamp =  FuelSDK::Campaign.new
		getCamp.authStub = stubObj
		getCamp.props = {"id" => IDOfpostCampaign}
		getResponse = getCamp.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.to_json
		p '-----------------------------'

  raise 'Failure retrieving campaign' unless getResponse.success?

		# Update the new Campaign
		p '>>> Update the new Campaign'
		patchCamp = FuelSDK::Campaign.new
		patchCamp.authStub = stubObj
		patchCamp.props = {"id"=> IDOfpostCampaign, "name" => "RubySDKCreated-Updated!"}
		patchResponse = patchCamp.patch
		p 'Patch Status: ' + patchResponse.status.to_s
		p 'Code: ' + patchResponse.code.to_s
		p 'Message: ' + patchResponse.message.to_s
		p 'Results: ' + patchResponse.results.to_json
		p '-----------------------------'

  raise 'Failure updating campaign' unless patchResponse.success?

		# Retrieve the updated Campaign
		p '>>> Retrieve the updated Campaign'
		getCamp = FuelSDK::Campaign.new
		getCamp.authStub = stubObj
		getCamp.props = {"id" => IDOfpostCampaign}
		getResponse = getCamp.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.to_json
		p '-----------------------------'

  raise 'Failure retrieving campaign' unless getResponse.success?

		# Create a new Campaign Asset
		p '>>> Create a new Campaign Asset'
		postCampAsset = FuelSDK::Campaign::Asset.new
		postCampAsset.authStub = stubObj
		postCampAsset.props = {"id" => IDOfpostCampaign, "ids"=> [ExampleAssetItemID], "type"=> ExampleAssetType}
		postResponse = postCampAsset.post
		p 'Post Status: ' + postResponse.status.to_s
		p 'Code: ' + postResponse.code.to_s
		p 'Message: ' + postResponse.message.to_s
		p 'Results: ' + postResponse.results.to_json
		p '-----------------------------'

  raise 'Failure creating campaign assets' unless postResponse.success?

		IDOfpostCampaignAsset = postResponse.results[0]['id']

		# Retrieve all Campaign Asset for a campaign
		p '>>> Retrieve all Campaign Asset for a Campaign'
		getCampAsset = FuelSDK::Campaign::Asset.new
		getCampAsset.authStub = stubObj
		getCampAsset.props = {"id" => IDOfpostCampaign}
		getResponse = getCampAsset.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.inspect
		p '-----------------------------'

  raise 'Failure retrieving campaign assets' unless getResponse.success?

		# Retrieve a single new Campaign Asset
		p '>>> Retrieve a single new Campaign Asset'
		getCampAsset = FuelSDK::Campaign::Asset.new
		getCampAsset.authStub = stubObj
		getCampAsset.props = {"id" => IDOfpostCampaign, "assetId" => IDOfpostCampaignAsset}
		getResponse = getCampAsset.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.inspect
		p '-----------------------------'

  raise 'Failure retrieving campaign asset' unless getResponse.success?

		# Delete the new Campaign Asset
		p '>>> Delete the new Campaign Asset'
		deleteCampAsset = FuelSDK::Campaign::Asset.new
		deleteCampAsset.authStub = stubObj
		deleteCampAsset.props = {"id" => IDOfpostCampaign, "assetId"=> IDOfpostCampaignAsset}
		deleteResponse = deleteCampAsset.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results: ' + deleteResponse.results.to_json
		p '-----------------------------'

  raise 'Failure deleting campaign asset' unless deleteResponse.success?

		# Get a single a new Campaign Asset to confirm deletion
		p '>>> Get a single a new Campaign Asset to confirm deletion'
		getCampAsset = FuelSDK::Campaign::Asset.new
		getCampAsset.authStub = stubObj
		getCampAsset.props = {"id" => IDOfpostCampaign}
		getResponse = getCampAsset.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.inspect
		p '-----------------------------'

  raise 'Failure retrieving campaign asset' unless getResponse.success?
  raise 'Failure retrieving campaign asset' unless getResponse.results['totalCount'] == 0

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace

ensure
		# Delete the new Campaign
		p '>>> Delete the new Campaign'
		deleteCamp = FuelSDK::Campaign.new
		deleteCamp.authStub = stubObj
		deleteCamp.props = {"id"=> IDOfpostCampaign}
		deleteResponse = deleteCamp.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results: ' + deleteResponse.results.to_json
		p '-----------------------------'

  raise 'Failure deleting campaign asset' unless deleteResponse.success?

		p '>>> Delete List'
		deleteSub = FuelSDK::List.new()
		deleteSub.authStub = stubObj
		deleteSub.props = {"ID" => ExampleAssetItemID}
		deleteResponse = deleteSub.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results Length: ' + deleteResponse.results.length.to_s
		p 'Results: ' + deleteResponse.results.to_s
end
