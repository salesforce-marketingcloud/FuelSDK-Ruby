module FuelSDK
  module Rest

    include FuelSDK::Targeting

    def rest_client
      self
    end

    def normalize_keys obj
      if obj and obj.is_a? Hash
        obj.keys.each do |k|
          obj[(k.to_sym rescue k) || k] = obj.delete(k)
        end
      end
      obj
    end

    def complete_url url, identities
      normalize_keys(identities)
      url = url % identities if identities
      url
    rescue KeyError => ex
      raise "#{ex.message} to complete #{url}"
    end

    def rest_get url, identities={}, params={}
      url = complete_url url, identites
      params.merge! 'access_token' => access_token
      (rest_client.get url, {'params' => params})
    end
  end
end
