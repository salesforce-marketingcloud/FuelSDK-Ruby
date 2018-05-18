#== Description
#
# This class was added in order to properly check whether a request to ET was
# successful or not. By default FuelSDK was checking only the HTTP status which
# was leading to false positives (a.k.a. not sending any emails without knowing)
#
#== Responsibilities
#
# Delegate to the original response class and modify the conditions of `success`

module FuelSDK
  class TriggeredSendResponse < SimpleDelegator

    def initialize(raw_response)
      super
    end

    def success
      return false if !__getobj__.success

      raw_hash = __getobj__.raw.hash
      envelope = raw_hash[:envelope]
      body = envelope[:body]
      create_response = body[:create_response]
      results = create_response[:results]
      results.nil? ? false : results[:status_message] == "Created TriggeredSend"
    end

    # these match the aliases in FuelSDK::Response
    alias :success? :success
    alias :status :success # backward compatibility
  end
end
