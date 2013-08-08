require 'fuelsdk'
require_relative 'sample_helper'

begin
	myclient = FuelSDK::Client.new auth
	
	DataExtensionCustomerKey = "62476204-bfd3-de11-95ca-001e0bbae8cc"
	CSVFileName = "SDKExample.csv"
	
=begin
	* Parameters:
		* Data Extension CustomerKey - CustomerKey values are displayed in the UI as External Key   
		* File Name - File must be a CSV located on your ExactTarget FTP Site
		* Overwrite (Boolean) - Set to True in order to overwrite all existing data in the data extension. Required if Data Extension does not have a primary key.
=end

	response = myclient.CreateAndStartDataExtensionImport(DataExtensionCustomerKey, CSVFileName, true)
	p 'Response Status: ' + response.status.to_s
	p 'Code: ' + response.code.to_s
	p 'Message: ' + response.message.to_s	
	p 'Results Length: ' + response.results.length.to_s
	p 'Results: ' + response.results.to_s
	
rescue => e
	p "Caught exception: #{e.message}"
	p e.backtrace
end


