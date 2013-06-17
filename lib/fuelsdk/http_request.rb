require 'open-uri'
require 'net/https'
require 'json'

module FuelSDK

  class HTTPResponse < FuelSDK::ET_Response

    def initialize raw, client, request
      super raw, client
      @request = request
    end

    def continue
      rsp = nil
      if more?
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
        @body = JSON.parse(raw.body)
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

    private

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
        response = http.request(_request)

        HTTPResponse.new(response, self, :url => url, :options => options)
      end
  end
end
