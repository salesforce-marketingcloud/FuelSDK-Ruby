require 'savon'
module FuelSDK

  class SoapResponse
    # not doing accessor so user, can't update these values from response.
    # You will see in the code some of these
    # items are being updated via back doors and such.
    attr_reader :code, :message, :results, :request_id, :body, :raw

    alias :status :code # backward compatibility
    # some defaults
    def success
      @success ||= false
    end
    alias :success? :success


    def more
      @more ||= false
    end
    alias :more? :more

    def initialize raw, client
      @client = client # keep connection with client in case we request more
      @results = []
      unpack raw
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
        @request_id = raw.body[raw.body.keys.first][:request_id]

        @message = parse_msg raw
        @success = @message == 'OK'


        @results += (parse_rslts raw)
      end

      def parse_msg raw
        raw.soap_fault? ? raw.body[:fault][:faultstring] : raw.body[raw.body.keys.first][:overall_status]
      end

      def parse_rslts raw
        @more = (raw.body[raw.body.keys.first][:overall_status] == 'MoreDataAvailable')
        rslts = raw.body[raw.body.keys.first][:results] || []
        rslts = [rslts] unless rslts.kind_of? Array
        rslts
      end
  end

  #class CUDResponse < SoapResponse
  #  private
  #    #def parse_msg raw
  #    #  raw.soap_fault? ? raw.body[:fault][:faultstring] : raw.body[raw.body.keys.first][:results][:status_message]
  #    #end

  #    def parse_rslts raw
  #      parsed = []
  #      rslts = raw.body[raw.body.keys.first][:results]
  #      rslts = [rslts] unless rslts.kind_of? Array
  #      rslts.each do |r|
  #        parsed << r[:object] if r.include? :object
  #      end
  #      parsed
  #    end
  #end

  class DescribeResponse < SoapResponse
    attr_reader :properties, :retrievable, :updatable, :required
    private
      def parse_rslts raw
        @retrievable, @updatable, @required, @properties = [], [], [], [], []
        rslts = raw.body[raw.body.keys.first][:object_definition][:properties]
        rslts.each do  |r|
          @retrievable << r[:name] if r[:is_retrievable]
          @updatable << r[:name] if r[:is_updatable]
          @required << r[:name] if r[:is_required]
          @properties << r[:name]
        end
        @success = true # overall_status is missing from definition response, so need to set here manually
        rslts
      rescue
        @message = "Unable to describe #{raw.locals[:message]['DescribeRequests']['ObjectDefinitionRequest']['ObjectType']}"
        @success = false
        nil
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

    def post object_type, properties
      _cud_ :create, object_type, properties
    end

    def patch object_type, properties
      _cud_ :update, object_type, properties
    end

    def delete object_type, properties
      _cud_ :delete, object_type, properties
    end

    private
      def _cud_ action, object_type, properties
        message = {
          'Objects' => properties,
          :attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + object_type) } }
        }
        SoapResponse.new client.call(action, :message => message), self
      end
  end
end
