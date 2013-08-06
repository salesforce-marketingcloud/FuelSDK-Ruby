require 'fuelsdk'
require_relative 'sample_helper'

begin
    stubObj = FuelSDK::Client.new auth
    
    NewImportName = "RubySDKImport"
    SendableDataExtensionCustomerKey = "62476204-bfd3-de11-95ca-001e0bbae8cc"
    ListIDForImport = "1956035"
    
    p '>>> Create Import to DataExtension'
    postImport = ET_Import.new 
    postImport.authStub = stubObj
    postImport.props = {"Name"=>NewImportName}
    postImport.props["CustomerKey"] = NewImportName
    postImport.props["Description"] = "Created with RubySDK"
    postImport.props["AllowErrors"] = "true"
    postImport.props["DestinationObject"] = {"ObjectID"=>SendableDataExtensionCustomerKey}
    postImport.props["FieldMappingType"] = "InferFromColumnHeadings"
    postImport.props["FileSpec"] = "RubyExample.csv"
    postImport.props["FileType"] = "CSV"
    postImport.props["Notification"] = {"ResponseType"=>"email","ResponseAddress"=>"example@example.com"}
    postImport.props["RetrieveFileTransferLocation"] = {"CustomerKey"=>"ExactTarget Enhanced FTP"}
    postImport.props["UpdateType"] = "Overwrite"
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
    postImport.props = {"Name"=>NewImportName}
    postImport.props["CustomerKey"] = NewImportName
    postImport.props["Description"] = "Created with RubySDK"
    postImport.props["AllowErrors"] = "true"
    postImport.props["DestinationObject"] = {"ID"=>ListIDForImport}
    postImport.props["FieldMappingType"] = "InferFromColumnHeadings"
    postImport.props["FileSpec"] = "RubyExample.csv"
    postImport.props["FileType"] = "CSV"
    postImport.props["Notification"] = {"ResponseType"=>"email","ResponseAddress"=>"example@example.com"}
    postImport.props["RetrieveFileTransferLocation"] = {"CustomerKey"=>"ExactTarget Enhanced FTP"}
    postImport.props["UpdateType"] = "AddAndUpdate"
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
    
    importStatus = ""
    while postResponse.status && importStatus != "Error" && importStatus != "Completed" do
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

