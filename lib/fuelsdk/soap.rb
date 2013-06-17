require 'savon'
module FuelSDK

  class SoapResponse < FuelSDK::ET_Response

    def continue
      rsp = nil
      if more?
       rsp = unpack @client.soap_client.call(:retrieve, :message => {'ContinueRequest' => request_id})
      else
        puts 'No more data'
      end

      rsp
    end

    private
      def unpack raw
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
        []
      end
  end

  module Soap
    attr_accessor :wsdl, :debug, :internal_token

    include FuelSDK::Targeting

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

    def soap_client
      self.refresh unless internal_token
      @soap_client ||= Savon.client(
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

    def soap_describe object_type
      message = {
        'DescribeRequests' => {
          'ObjectDefinitionRequest' => {
            'ObjectType' => object_type
          }
        }
      }

      DescribeResponse.new soap_client.call(:describe, :message => message), self
    end

    def soap_get object_type, properties=nil, filter=nil
      if properties.nil?
        rsp = soap_describe object_type
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

      soap_request :retrieve, :message => message
    end

    def soap_post object_type, properties
      soap_cud :create, object_type, properties
    end

    def soap_patch object_type, properties
      soap_cud :update, object_type, properties
    end

    def soap_delete object_type, properties
      soap_cud :delete, object_type, properties
    end

    private
      def soap_cud action, object_type, properties
        message = {
          'Objects' => properties,
          :attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + object_type) } }
        }
        soap_request action, :message => message
      end

      def soap_request action, message
          retried = false
          begin
            rsp = soap_client.call(action, message)
          rescue
            raise if retried
            retried = true
            retry
          end
          SoapResponse.new rsp, self
      rescue
        SoapResponse.new rsp, self
      end
  end
end
