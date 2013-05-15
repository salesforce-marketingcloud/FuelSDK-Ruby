require '../ET_Client.rb'
require 'securerandom'

begin
	stubObj = ET_Client.new(false, false)	
	
	NewImportName = "RubySDKImport"
	SendableDataExtensionCustomerKey = "62476204-bfd3-de11-95ca-001e0bbae8cc"
	ListIDForImport = "1956035"

	p '>>> Create Import to DataExtension'
	postImport = ET_Import.new 
	postImport.authStub = stubObj
	postImport.props = {"Name"=>NewImportName, "CustomerKey"=>NewImportName, "Description"=>"Created with RubySDK", "AllowErrors"=>"true", "DestinationObject"=>{"ObjectID"=>SendableDataExtensionCustomerKey}, "FieldMappingType"=> "InferFromColumnHeadings", "FileSpec"=>"RubyExample.csv", "FileType"=>"CSV", "Notification"=>{"ResponseType"=>"email","ResponseAddress"=>"example@example.com"},"RetrieveFileTransferLocation"=>{"CustomerKey"=>"ExactTarget Enhanced FTP"}, "UpdateType"=>"Overwrite"}
	postResponse = postImport.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
	
	p '>>> Delete Import'
	deleteImport = ET_Import.new()
	deleteImport.authStub = stubObj
	deleteImport.props = {"CustomerKey" => NewImportName}
	deleteResponse = deleteImport.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s	
	p 'Results Length: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.to_s

	p '>>> Create Import to List'
	postImport = ET_Import.new 
	postImport.authStub = stubObj
	postImport.props = {"Name"=>NewImportName, "CustomerKey"=>NewImportName, "Description"=>"Created with RubySDK", "AllowErrors"=>"true", "DestinationObject"=>{"ID"=>ListIDForImport}, "FieldMappingType"=> "InferFromColumnHeadings", "FileSpec"=>"RubyExample.csv", "FileType"=>"CSV", "Notification"=>{"ResponseType"=>"email","ResponseAddress"=>"example@example.com"},"RetrieveFileTransferLocation"=>{"CustomerKey"=>"ExactTarget Enhanced FTP"}, "UpdateType"=>"AddAndUpdate"}
	postResponse = postImport.post
	p 'Post Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect

	p '>>> Start Import to List'
	startImport = ET_Import.new 
	startImport.authStub = stubObj
	startImport.props = {"CustomerKey"=>NewImportName}
	postResponse = startImport.start
	p 'Start Status: ' + postResponse.status.to_s
	p 'Code: ' + postResponse.code.to_s
	p 'Message: ' + postResponse.message.to_s
	p 'Result Count: ' + postResponse.results.length.to_s
	p 'Results: ' + postResponse.results.inspect
	
	p '>>> Check Status using the same instance of ET_Import as used for start'
	importStatus = ""
	while importStatus != "Error" && importStatus != "Completed"  do
		p '>>> Checking status in loop'
		# Wait a bit before checking the status to give it time to process
		sleep 30
		statusResponse = startImport.status
		p 'Status Status: ' + statusResponse.status.to_s
		p 'Code: ' + statusResponse.code.to_s
		p 'Message: ' + statusResponse.message.to_s
		p 'Result Count: ' + statusResponse.results.length.to_s
		p 'Results: ' + statusResponse.results.inspect
		importStatus = statusResponse.results[0][:import_status]
	end

	p '>>> Delete Import'
	deleteImport = ET_Import.new()
	deleteImport.authStub = stubObj
	deleteImport.props = {"CustomerKey" => NewImportName}
	deleteResponse = deleteImport.delete
	p 'Delete Status: ' + deleteResponse.status.to_s
	p 'Code: ' + deleteResponse.code.to_s
	p 'Message: ' + deleteResponse.message.to_s	
	p 'Results Length: ' + deleteResponse.results.length.to_s
	p 'Results: ' + deleteResponse.results.to_s
		
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end

