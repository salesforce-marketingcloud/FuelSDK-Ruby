=begin
Copyright (c) 2013 ExactTarget, Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 

following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the 

following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 

following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 

products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 

INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 

DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 

SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 

SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 

WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 

USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end

module MarketingCloudSDK
  module Rest

    include MarketingCloudSDK::Targeting

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

    private
      def rest_request action, url, options={}
        #Try to refresh the token and if we do then we need to regenerate the header as well.
        self.refresh
        (options['params'] ||= {})

        if access_token
          options['access_token'] = access_token
        end

        rsp = rest_client.send(action, url, options)
        raise 'Unauthorized' if rsp.message == 'Unauthorized'

        rsp
      end
  end
end
