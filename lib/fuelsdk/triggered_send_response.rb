module FuelSDK
  class TriggeredSendResponse

    # TODO delegate all methods except success? and success to raw_response
    attr_reader :raw_response

    def initialize(raw_response)
      @raw_response = raw_response
    end

    def success
      false
    end
  end
end