require 'savon'
module FuelSDK

  class SoapResponse
    # not doing accessor so user, can't update these values from response.
    # You will see in the code some of these
    # items are being updated via back doors and such.
    attr_reader :status, :code, :message, :results, :request_id, :body, :raw, :success, :more

    alias :success? :success
    alias :more? :more

    def initialize raw, client
      @client = client # keep connection with client in case we request more
      @results = []
      unpack raw
      @success = @message == 'OK'
    end

    def continue
      rsp = nil
      if more?
       rsp = unpack @client.client.call(:retrieve, :message => {'ContinueRequest' => request_id})
      else
        puts 'No more data'
      end

      rsp
    end

    private
      def unpack raw
        @raw = raw
        @body = raw.body
        @code = raw.http.code
        @message =  raw.soap_fault? ? raw.body[:fault][:faultstring] : raw.body[raw.body.keys.first][:overall_status]
        @request_id = raw.body[raw.body.keys.first][:request_id]
        @more = (raw.body[raw.body.keys.first][:overall_status] == 'MoreDataAvailable')
        if raw.body[raw.body.keys.first][:results]
          @results.concat raw.body[raw.body.keys.first][:results]
        end
      end
  end

  class DescribeResponse < SoapResponse
    attr_reader :properties, :retrievable, :updatable, :required
    def initialize raw, client
      super raw, client

      @retrievable, @updatable, @required, @properties = [], [], [], [], []
      @results = raw.body[raw.body.keys.first][:object_definition][:properties]
      @results.each do  |r|
        @retrievable << r[:name] if r[:is_retrievable]
        @updatable << r[:name] if r[:is_updatable]
        @required << r[:name] if r[:is_required]
        @properties << r[:name]
      end

      @success = true # overall_status is missing from definition response, so need to set here manually
    rescue
      @message = "Unable to describe #{raw.locals[:message]['DescribeRequests']['ObjectDefinitionRequest']['ObjectType']}"
      @success = false
    end
  end

  module Soap
    attr_accessor :wsdl, :debug, :internal_token

    include FuelSDK::Targeting

    def mode
      "soap"
    end

    def header
      raise 'Require legacy token for soap header' unless internal_token
      {
        'oAuth' => {'oAuthToken' => internal_token},
        :attributes! => { 'oAuth' => { 'xmlns' => 'http://exacttarget.com' }}
      }
    end

    def debug
      @debug ||= false
    end

    def wsdl
      @wsdl ||= 'https://webservice.exacttarget.com/etframework.wsdl'
    end

    def client
      self.refresh unless internal_token
      @client ||= Savon.client(
        soap_header: header,
        wsdl: wsdl,
        endpoint: endpoint,
        wsse_auth: ["*", "*"],
        raise_errors: false,
        log: debug,
        open_timeout:180,
        read_timeout: 180
      )
    end

    def describe object_type
      message = {
        'DescribeRequests' => {
          'ObjectDefinitionRequest' => {
            'ObjectType' => object_type
          }
        }
      }

      DescribeResponse.new client.call(:describe, :message => message), self
    end

    def normalize object_type
      object_type.capitalize.singularize
    end

    def get object_type, properties=nil, filter=nil
      if properties.nil?
        rsp = describe object_type
        if rsp.success?
          properties = rsp.retrievable
        else
          rsp.instance_variable_set(:@message, "Unable to get #{object_type}") # back door update
          return rsp
        end
      elsif properties.kind_of? Hash
        properties = properties.keys
      elsif properties.kind_of? String
        properties = [properties]
      end

      message = {'ObjectType' => object_type, 'Properties' => properties}

      if filter and filter.kind_of? Hash
        message['Filter'] = filter
        message[:attributes!] = { 'Filter' => { 'xsi:type' => 'tns:SimpleFilterPart' } }

        if filter.has_key?('LogicalOperator')
          message[:attributes!] = { 'Filter' => { 'xsi:type' => 'tns:ComplexFilterPart' }}
          message['Filter'][:attributes!] = {
            'LeftOperand' => { 'xsi:type' => 'tns:SimpleFilterPart' },
            'RightOperand' => { 'xsi:type' => 'tns:SimpleFilterPart' }}
        end
      end
      message = {'RetrieveRequest' => message}

      SoapResponse.new client.call(:retrieve, :message => message), self
    end
  end

  #{"Objects"=>{"EmailAddress"=>"RubySDKExample@bh.exacttarget.com"},
  # :attributes!=>{"Objects"=>{"xsi:type"=>"tns:Subscriber"}}}
  def post object_type, properties
  end

  def delete object_type, properties
  end

  def delete object_type, properties
  end
end
