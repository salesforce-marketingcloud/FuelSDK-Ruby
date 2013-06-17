module FuelSDK
  module Rest

    include FuelSDK::Targeting

    def rest
      self
    end

    def rest_get url, params={}
      params.merge! 'access_token' => access_token
      (rest.get url, options)
    end
  end
end
