require 'fuelsdk'
require_relative 'sample_helper' # contains auth with credentials

begin
  filter = {'Property' =>  'Type','SimpleOperator' => 'equals','Value' => 'Public'}  
  client = ET_Client.new auth 
  getResponse = ET_Get.new client, 'List', nil, filter
  p "Get Status: #{getResponse.status.to_s}"
  p "Code: #{getResponse.code.to_s}"
  p "Message: #{getResponse.message.to_s}"
  p "Result Count: #{getResponse.results.length.to_s}"  
  p "Results: #{getResponse.results.inspect}"
  raise 'Failure getting List info' unless getResponse.success?
    
  NewListName = "RubySDKList"
  props = {"ListName" => NewListName, "Description" => "This list was created with the RubySDK", "Type" => "Private" }
  client = ET_Client.new auth 
  postResponse = ET_Post.new client, 'List', props
  p "Post Status: #{postResponse.status.to_s}"
  p "Code: #{postResponse.code.to_s}"
  p "Message: #{postResponse.message.to_s}"
  p "Result Count: #{postResponse.results.length.to_s}"  
  p "Results: #{postResponse.results.inspect}"
  raise 'Failure Creating List' unless postResponse.success?
  
  	if postResponse.success? then		
		newListID = postResponse.results[0][:new_id]
		p "New ID: #{newListID}"
		
		props = {"ID" => newListID, "Description" => "Update!!!"}
		client = ET_Client.new auth 
		patchResponse = ET_Patch.new client, 'List', props
		p "Patch Status: #{patchResponse.status.to_s}"
		p "Code: #{patchResponse.code.to_s}"
		p "Message: #{patchResponse.message.to_s}"
		p "Result Count: #{patchResponse.results.length.to_s}"  
		p "Results: #{patchResponse.results.inspect}"
		raise 'Failure Patching List' unless patchResponse.success?
		
		
		props = {"ID" => newListID}
		client = ET_Client.new auth 
		deleteResponse = ET_Delete.new client, 'List', props
		p "Delete Status: #{deleteResponse.status.to_s}"
		p "Code: #{deleteResponse.code.to_s}"
		p "Message: #{deleteResponse.message.to_s}"
		p "Result Count: #{deleteResponse.results.length.to_s}"  
		p "Results: #{deleteResponse.results.inspect}"
		raise 'Failure Deleting List' unless deleteResponse.success?
	end 

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace
end