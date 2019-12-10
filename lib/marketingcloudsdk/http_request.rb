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

require 'open-uri'
require 'net/https'
require 'json'
require 'marketingcloudsdk/version'

module MarketingCloudSDK

  class HTTPResponse < MarketingCloudSDK::Response
    def initialize raw, client, request
      super raw, client
      @request = request
    end

    def continue
      rsp = nil
      if more?
       @request['options']['page'] = @results['page'].to_i + 1
       rsp = unpack @client.rest_get(@request['url'], @request['options'])
      else
        puts 'No more data'
      end

      rsp
    end

    def [] key
      @results[key]
    end

    private
      def unpack raw
        @code = raw.code.to_i
        @message = raw.message
        @body = JSON.parse(raw.body) rescue {}
        @results = @body
        @more = ((@results['count'] || @results['totalCount']) > @results['page'] * @results['pageSize']) rescue false
        @success = @message == 'OK'
      end

      # by default try everything against results
      def method_missing method, *args, &block
        @results.send(method, *args, &block)
      end
  end

  module HTTPRequest
    request_methods = ['get', 'post', 'patch', 'delete']
    request_methods.each do |method|
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{method}(url, options={})                                      # def post(url, options)
          request Net::HTTP::#{method.capitalize}, url, options             #   request Net::HTTP::Post, url, options
        end                                                                 # end
      EOT
    end

    def generate_uri(url, params=nil)
      uri = URI.parse(url)
      uri.query = URI.encode_www_form(params) if params
      uri
    end

    def request(method, url, options={})
      uri = generate_uri url, options['params']
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      data = options['data']
      _request = method.new uri.request_uri
      _request.body = data.to_json if data
      _request.content_type = options['content_type'] if options['content_type']
      _request.add_field('User-Agent', 'FuelSDK-Ruby-v' + MarketingCloudSDK::VERSION)

      # Add Authorization header if we have an access token
      if options['access_token']
        _request.add_field('Authorization', 'Bearer ' + options['access_token'])
      end

      response = http.request(_request)
      HTTPResponse.new(response, self, :url => url, :options => options)
    end
  end
end
