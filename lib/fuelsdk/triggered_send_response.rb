module FuelSDK
  class TriggeredSendResponse
    # TODO: delegate all methods except success? and success to raw_response
    attr_reader :raw_response

    def initialize(raw_response)
      @raw_response = raw_response
    end

    def success
      @raw_response.success

      # TODO: use @results from raw_response - has already been unpacked
      # @success = raw.hash[:envelope][:body][:create_response][:results][:status_message] == "Created TriggeredSend"
    end

    # these match the aliases in FuelSDK::Response
    alias :success? :success
    alias :status :success # backward compatibility
  end
end
