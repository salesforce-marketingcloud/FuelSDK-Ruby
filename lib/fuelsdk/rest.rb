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

    def get_url_properties url, properties
      url_property_names = url.scan(/(%{(.+?)})/).collect{|frmt, name| name}
      url_properties = {}
      properties.keys.each do |k|
        if url_property_names.include? k
          url_properties[k] = properties.delete(k)
        end
      end
      url_properties
    end

    def complete_url url, url_properties
      normalize_keys(url_properties)
      url = url % url_properties if url_properties
      url.end_with?('/') ? url.chop : url
    rescue KeyError => ex
      raise "#{ex.message} to complete #{url}"
    end

    def parse_properties url, properties
      url_properties = get_url_properties url, properties
      url = complete_url url, url_properties
      [url, properties]
    end

    def rest_get url, properties={}
      url, properties = parse_properties url, properties
      rest_request :get, url, {'params' => properties}
    end

    def rest_delete url, properties={}
      url, properties = parse_properties url, properties
      rest_request :delete, url
    end

    def rest_patch url, properties={}
      url, payload = parse_properties url, properties
      rest_request :patch, url, {'data' => payload,
        'content_type' => 'application/json'}
    end

    def rest_post url, properties={}
      url, payload = parse_properties url, properties
      rest_request :post, url, {'data' => payload,
        'content_type' => 'application/json'}
    end

    def rest_request action, url, options
      retried = false
      begin
        (options['params'] ||= {}).merge! 'access_token' => access_token
        binding.pry
        rsp = rest_client.send(action, url, options)
        raise 'Unauthorized' if rsp.message == 'Unauthorized'
      rescue
        raise if retried
        self.refresh! # ask for forgiveness not, permission
        retried = true
        retry
      end
        rsp
    rescue
      rsp
    end
  end
end
