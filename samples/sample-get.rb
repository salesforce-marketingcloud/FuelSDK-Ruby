require 'fuelsdk'
require_relative 'sample_helper' # contains auth with credentials

begin
  client = ET_Client.new auth
  get = ET_Get.new client, 'Account'
  p "Results: #{get.results}"
  raise 'Failure getting Account info' unless get.success?

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace
end
