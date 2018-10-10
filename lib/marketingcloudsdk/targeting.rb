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

require 'json'

module MarketingCloudSDK::Targeting
  attr_accessor :access_token
  attr_reader :endpoint, :soap_endpoint

  include MarketingCloudSDK::HTTPRequest

  def cache_file
    'soap_cache_file.json'
  end

  def endpoint
    unless @endpoint
      get_soap_endpoint
    end
    @endpoint
  end

  def get_soap_endpoint_from_file
    data_hash = nil

    if File.exist? cache_file
      file = File.read(cache_file)
      data_hash = JSON.parse(file)
    end

    data_hash
  end

  def set_soap_endpoint_to_file url
    data_hash = {
        'url' => url,
        'timestamp' => Time.new.to_f + (10 * 60)
    }

    File.open(cache_file, 'w') do |f|
      f.write(JSON.generate(data_hash))
    end
  end

  protected
    def get_soap_endpoint
      if self.soap_endpoint
        @endpoint = self.soap_endpoint
        return
      end

      cache_data = get_soap_endpoint_from_file

      if cache_data.nil? === false and not cache_data['url'].nil? and cache_data['timestamp'].to_f > Time.new.to_f
        @endpoint = cache_data['url']
        return
      end

      options = {'access_token' => self.access_token}
      response = get(self.base_api_url +  "/platform/v1/endpoints/soap", options)
      @endpoint = response['url']
      set_soap_endpoint_to_file @endpoint
    rescue => e
      @endpoint = 'https://webservice.exacttarget.com/Service.asmx'
    end
end
