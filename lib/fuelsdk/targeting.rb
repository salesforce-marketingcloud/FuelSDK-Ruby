module FuelSDK::Targeting
  attr_accessor :access_token
  attr_reader :endpoint

  include FuelSDK::HTTPRequest

  def endpoint
    unless @endpoint
      determine_stack
    end
    @endpoint
  end

  protected
    def determine_stack
      response = _get_("https://www.exacttargetapis.com/platform/v1/endpoints/soap?access_token=#{self.access_token}")
      @endpoint = response['url']
    rescue => e
      raise 'Unable to determine stack using: ' + e.message
    end
end

