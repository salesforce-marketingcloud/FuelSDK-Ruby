require 'fuelsdk'
require_relative 'sample_helper' # contains auth with credentials

begin
  client = ET_Client.new auth
  request = ET_Get.new client, 'Account'
  rsp = request.get
  p "Results: #{rsp.results}"
  raise 'Failure getting Account info' unless rsp.success?

rescue => e
  p "Caught exception: #{e.message}"
  p e.backtrace
end
