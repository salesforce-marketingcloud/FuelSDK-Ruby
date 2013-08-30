require 'savon'
module FuelSDK

  class SoapResponse < FuelSDK::Response

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
      def unpack_body raw
        @body = raw.body
        @request_id = raw.body[raw.body.keys.first][:request_id]
        unpack_msg raw
      rescue
        @message = raw.http.body
        @body = raw.http.body unless @body
      end

      def unpack raw
        @code = raw.http.code
        unpack_body raw
        @success = @message == 'OK'
        @results += (unpack_rslts raw)
      end

      def unpack_msg raw
        @message = raw.soap_fault? ? raw.body[:fault][:faultstring] : raw.body[raw.body.keys.first][:overall_status]
      end

      def unpack_rslts raw
        @more = (raw.body[raw.body.keys.first][:overall_status] == 'MoreDataAvailable')
        rslts = raw.body[raw.body.keys.first][:results] || []
        rslts = [rslts] unless rslts.kind_of? Array
        rslts
      rescue
        []
      end
  end

  class DescribeResponse < SoapResponse
    attr_reader :properties, :retrievable, :updatable, :required, :extended, :viewable, :editable
    private

      def unpack_rslts raw
        @retrievable, @updatable, @required, @properties, @extended, @viewable, @editable = [], [], [], [], [], [], [], []
        definition = raw.body[raw.body.keys.first][:object_definition]
        _props = definition[:properties]
        _props.each do  |p|
          @retrievable << p[:name] if p[:is_retrievable] and (p[:name] != 'DataRetentionPeriod')
          @updatable << p[:name] if p[:is_updatable]
          @required << p[:name] if p[:is_required]
          @properties << p[:name]
        end
        # ugly, but a necessary evil
        _exts = definition[:extended_properties].nil? ? {} : definition[:extended_properties] # if they have no extended properties nil is returned
        _exts = _exts[:extended_property] || [] # if no properties nil and we need an array to iterate
        _exts = [_exts] unless _exts.kind_of? Array # if they have only one extended property we need to wrap it in array to iterate
        _exts.each do  |p|
          @viewable << p[:name] if p[:is_viewable]
          @editable << p[:name] if p[:is_editable]
          @extended << p[:name]
        end
        @success = true # overall_status is missing from definition response, so need to set here manually
        _props + _exts
      rescue
        @message = "Unable to describe #{raw.locals[:message]['DescribeRequests']['ObjectDefinitionRequest']['ObjectType']}"
        @success = false
        []
      end
  end

  module Soap
    attr_accessor :wsdl, :debug#, :internal_token

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
      self.refresh
      @soap_client = Savon.client(
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
      soap_request :describe, message
    end
  
    def soap_perform object_type, action, properties
      message = {}
      message['Action'] = action
      message['Definitions'] = {'Definition' => properties}
      message['Definitions'][:attributes!] = { 'Definition' => { 'xsi:type' => ('tns:' + object_type) }}

      soap_request :perform, message
    end
    
    
    def soap_configure  object_type, action, properties
     message = {}
     message['Action'] = action
     message['Configurations'] = {}

     message['Configurations']['Configuration'] = []
     properties.each do |configItem|
       message['Configurations']['Configuration'] << configItem
     end

     message['Configurations'][:attributes!] = { 'Configuration' => { 'xsi:type' => ('tns:' + object_type) }}
     
     soap_request :configure, message
    end

    def soap_get object_type, properties=nil, filter=nil
      if properties.nil? or properties.empty?
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

      soap_request :retrieve, message
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
		
=begin
        # get a list of attributes so we can seperate
        # them from standard object properties
        type_attrs = soap_describe(object_type).editable	

=end
        properties = [properties] unless properties.kind_of? Array
=begin		
        properties.each do |p|
          formated_attrs = []
          p.each do |k, v|
            if type_attrs.include? k
              p.delete k
              attrs = FuelSDK.format_name_value_pairs k => v
              formated_attrs.concat attrs
            end
          end
          (p['Attributes'] ||= []).concat formated_attrs unless formated_attrs.empty?
        end
=end

        message = {
          'Objects' => properties,
          :attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + object_type) } }
        }
        soap_request action, message
      end

      def soap_request action, message
        response = action.eql?(:describe) ? DescribeResponse : SoapResponse
        retried = false
        begin
          rsp = soap_client.call(action, :message => message)
        rescue
          raise if retried
          retried = true
          retry
        end
        response.new rsp, self
      rescue
        raise if rsp.nil?
        response.new rsp, self
      end
  end
end
