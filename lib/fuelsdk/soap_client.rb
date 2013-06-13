module FuelSDK
  class SoapClient < ET_Client
    def initialize(params={}, debug=false)
      params.merge! 'type' => 'soap'
      super(params, debug)
    end
  end
end
