module FuelSDK
  class TriggeredSendResponse < SimpleDelegator

    def initialize(raw_response)
      super
    end

    def success
      triggered_send_successful = __getobj__.raw.hash[:envelope][:body][:create_response][:results][:status_message] == "Created TriggeredSend"

      __getobj__.success && triggered_send_successful
    end

    # these match the aliases in FuelSDK::Response
    alias :success? :success
    alias :status :success # backward compatibility
  end
end
