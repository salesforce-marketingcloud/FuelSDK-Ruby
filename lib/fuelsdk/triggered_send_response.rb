module FuelSDK
  class TriggeredSendResponse < SimpleDelegator

    def initialize(raw_response)
      super
    end

    def success
      __getobj__.success

      # TODO: use @results from raw_response - has already been unpacked
      # @success = raw.hash[:envelope][:body][:create_response][:results][:status_message] == "Created TriggeredSend"
    end

    # these match the aliases in FuelSDK::Response
    alias :success? :success
    alias :status :success # backward compatibility
  end
end
