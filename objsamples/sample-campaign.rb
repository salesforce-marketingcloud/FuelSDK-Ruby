require '../etClient.rb'


begin 
	stubObj = ETClient.new(false, false)
	
	# Create a new Campaign
	p '>>> Create a new Campaign'
	postCamp = ET_Campaign.new
	postCamp.authStub = stubObj
	postCamp.props = {"name" => "RubySDKCreatedForTest", "description"=> "RubySDKCreatedForTest", "color"=>"FF9933", "favorite"=>"false"}
	postResponse = postCamp.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Results: ' + postResponse.results.to_json	
	p '-----------------------------'

	if postResponse.status then

		IDOfpostCampaign = postResponse.results['id']

		# Retrieve the new Campaign
		p '>>> Retrieve the new Campaign'
		getCamp = ET_Campaign.new
		getCamp.authStub = stubObj
		getCamp.props = {"id" => IDOfpostCampaign}
		getResponse = getCamp.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.to_json
		p '-----------------------------'

		# Update the new Campaign
		p '>>> Update the new Campaign'
		patchCamp = ET_Campaign.new
		patchCamp.authStub = stubObj
		patchCamp.props = {"id"=> IDOfpostCampaign, "name" => "RubySDKCreated-Updated!"}
		postResponse = patchCamp.patch
		p 'Patch Status: ' + postResponse.status.to_s
		p 'Code: ' + postResponse.code.to_s
		p 'Message: ' + postResponse.message.to_s
		p 'Results: ' + postResponse.results.to_json	
		p '-----------------------------'

		# Retrieve the updated Campaign
		p '>>> Retrieve the updated Campaign'
		getCamp = ET_Campaign.new
		getCamp.authStub = stubObj
		getCamp.props = {"id" => IDOfpostCampaign}
		getResponse = getCamp.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.to_json
		p '-----------------------------'

		ExampleAssetType = "LIST"
		ExampleAssetItemID = "1953114"

		# Create a new Campaign Asset
		p '>>> Create a new Campaign Asset'
		postCampAsset = ET_Campaign::Asset.new
		postCampAsset.authStub = stubObj
		postCampAsset.props = {"id" => IDOfpostCampaign, "ids"=> [ExampleAssetItemID], "type"=> ExampleAssetType}
		postResponse = postCampAsset.post
		p 'Post Status: ' + postResponse.status.to_s
		p 'Code: ' + postResponse.code.to_s
		p 'Message: ' + postResponse.message.to_s
		p 'Results: ' + postResponse.results.to_json	
		p '-----------------------------'

		IDOfpostCampaignAsset = postResponse.results[0]['id']

		# Get all Campaign Asset for a campaign
		p '>>> Get all Campaign Asset for a Campaign'
		getCampAsset = ET_Campaign::Asset.new
		getCampAsset.authStub = stubObj
		getCampAsset.props = {"id" => IDOfpostCampaign}
		getResponse = getCampAsset.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.inspect
		p '-----------------------------'

		# Get a single a new Campaign Asset
		p '>>> Get a single a new Campaign Asset'
		getCampAsset = ET_Campaign::Asset.new
		getCampAsset.authStub = stubObj
		getCampAsset.props = {"id" => IDOfpostCampaign, "assetId" => IDOfpostCampaignAsset}
		getResponse = getCampAsset.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.inspect
		p '-----------------------------'

		# Delete the new Campaign Asset
		p '>>> Delete the new Campaign Asset'
		deleteCampAsset = ET_Campaign::Asset.new
		deleteCampAsset.authStub = stubObj
		deleteCampAsset.props = {"id" => IDOfpostCampaign, "assetId"=> IDOfpostCampaignAsset}
		deleteResponse = deleteCampAsset.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results: ' + deleteResponse.results.to_json	
		p '-----------------------------'

		# Get a single a new Campaign Asset to confirm deletion
		p '>>> Get a single a new Campaign Asset to confirm deletion'
		getCampAsset = ET_Campaign::Asset.new
		getCampAsset.authStub = stubObj
		getCampAsset.props = {"id" => IDOfpostCampaign, "assetId" => IDOfpostCampaignAsset}
		getResponse = getCampAsset.get
		p 'Retrieve Status: ' + getResponse.status.to_s
		p 'Code: ' + getResponse.code.to_s
		p 'Message: ' + getResponse.message.to_s
		p 'Results: ' + getResponse.results.inspect
		p '-----------------------------'

		# Delete the new Campaign
		p '>>> Delete the new Campaign'
		deleteCamp = ET_Campaign.new
		deleteCamp.authStub = stubObj
		deleteCamp.props = {"id"=> IDOfpostCampaign}
		deleteResponse = deleteCamp.delete
		p 'Delete Status: ' + deleteResponse.status.to_s
		p 'Code: ' + deleteResponse.code.to_s
		p 'Message: ' + deleteResponse.message.to_s
		p 'Results: ' + deleteResponse.results.to_json	
		p '-----------------------------'

	end

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace
end
