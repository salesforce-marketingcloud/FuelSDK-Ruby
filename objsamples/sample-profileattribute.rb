require '../ET_Client.rb'

begin
	stubObj = ET_Client.new(false, false)
	
	NameOfAttribute = 'RubySDKTestAttribute'
	
	p '>>> Create ProfileAttribute'
	postProfileAttribute = ET_ProfileAttribute.new 
	postProfileAttribute.authStub = stubObj
	postProfileAttribute.props = {"Name" => NameOfAttribute, "PropertyType"=>"string", "Description"=>"New Attribute from the SDK", "IsRequired"=>"false", "IsViewable"=>"false", "IsEditable"=>"true", "IsSendTime"=>"false"}
	postResponse = postProfileAttribute.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
	
	p '>>> Retrieve All ProfileAttributes'
	getProfileAttribute = ET_ProfileAttribute.new 
	getProfileAttribute.authStub = stubObj
	getResponse = getProfileAttribute.get
	p 'Get Status: ' + getResponse.status.to_s
	p 'Code: ' + getResponse.code.to_s
	p 'Message: ' + getResponse.message.to_s
	p 'Result Count: ' + getResponse.results.length.to_s
	p 'Results: ' + getResponse.results.inspect
	
	p '>>> Update ProfileAttribute'
	patchProfileAttribute = ET_ProfileAttribute.new 
	patchProfileAttribute.authStub = stubObj
	patchProfileAttribute.props = {"Name" => NameOfAttribute, "PropertyType"=>"string"}
	patchResponse = patchProfileAttribute.patch
	p 'Patch Status: ' + patchResponse.status.to_s
	p 'Code: ' + patchResponse.code.to_s
	p 'Message: ' + patchResponse.message.to_s
	p 'Result Count: ' + patchResponse.results.length.to_s
	p 'Results: ' + patchResponse.results.inspect

	p '>>> Delete ProfileAttribute'
	deleteProfileAttribute = ET_ProfileAttribute.new 
	deleteProfileAttribute.authStub = stubObj
	deleteProfileAttribute.props = {"Name" => NameOfAttribute, "PropertyType"=>"string"}
	deleteResponse = deleteProfileAttribute.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s
	p 'Result Count: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.inspect

rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

