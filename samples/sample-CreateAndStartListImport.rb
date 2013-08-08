require 'fuelsdk'
require_relative 'sample_helper'

begin
	myclient = FuelSDK::Client.new auth
	ListID = "1956035"
	CSVFileName = "SDKExample.csv"
	
=begin
	* Parameters:
		* List ID  
		* File Name - File must be a CSV located on your ExactTarget FTP Site
=end
	
	response = myclient.CreateAndStartListImport(ListID, CSVFileName)
	p 'Response Status: ' + response.status.to_s
	p 'Code: ' + response.code.to_s
	p 'Message: ' + response.message.to_s	
	p 'Results Length: ' + response.results.length.to_s
	p 'Results: ' + response.results.to_s
	
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end


