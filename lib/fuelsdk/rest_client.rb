module FuelSDK
  class RestClient < ET_Client
    def initialize(params={}, debug=false)
      params.merge! 'type' => 'rest'
      params.delete! 'wsdl'
      super(params, debug)
    end
  end
end
