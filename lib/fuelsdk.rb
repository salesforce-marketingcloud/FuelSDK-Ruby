require "fuelsdk/version"

require 'rubygems'
require 'date'
require 'jwt'

module FuelSDK
  autoload :HTTPRequest, 'fuelsdk/http_request'
  autoload :Targeting, 'fuelsdk/targeting'
  autoload :Soap, 'fuelsdk/soap'
  autoload :Rest, 'fuelsdk/rest'
  require 'fuelsdk/client'
  require 'fuelsdk/objects'
end

# backwards compatability
ET_Client = FuelSDK::ET_Client
ET_Subscriber = FuelSDK::ET_Subscriber

=begin
  class ET_DataExtension < ET_CUDSupport
    attr_accessor :columns

    def initialize
      super
      @obj = 'DataExtension'
    end

    def post
      originalProps = @props

      if @props.is_a? Array then
        multiDE = []
        @props.each { |currentDE|
          currentDE['Fields'] = {}
          currentDE['Fields']['Field'] = []
          currentDE['columns'].each { |key|
            currentDE['Fields']['Field'].push(key)
          }
          currentDE.delete('columns')
          multiDE.push(currentDE.dup)
        }

        @props = multiDE
      else
        @props['Fields'] = {}
        @props['Fields']['Field'] = []

        @columns.each { |key|
        @props['Fields']['Field'].push(key)
        }
      end

      obj = super
      @props = originalProps
      return obj
    end

    def patch
      @props['Fields'] = {}
      @props['Fields']['Field'] = []
      @columns.each { |key|
        @props['Fields']['Field'].push(key)
      }
      obj = super
      @props.delete("Fields")
      return obj
    end

    class Column < ET_GetSupport
      def initialize
        super
        @obj = 'DataExtensionField'
      end

      def get

        if props and props.is_a? Array then
          @props = props
        end

        if @props and @props.is_a? Hash then
          @props = @props.keys
        end

        if filter and filter.is_a? Hash then
          @filter = filter
        end

        fixCustomerKey = false
        if filter and filter.is_a? Hash then
          @filter = filter
          if @filter.has_key?("Property") && @filter["Property"] == "CustomerKey" then
            @filter["Property"]  = "DataExtension.CustomerKey"
            fixCustomerKey = true
          end
        end

        obj = ET_Get.new(@authStub, @obj, @props, @filter)
        @lastRequestID = obj.request_id

        if fixCustomerKey then
          @filter["Property"] = "CustomerKey"
        end

        return obj
      end
    end

    class Row < ET_CUDSupport
      attr_accessor :Name, :CustomerKey

      def initialize()
        super
        @obj = "DataExtensionObject"
      end

      def get
        getName
        if props and props.is_a? Array then
          @props = props
        end

        if @props and @props.is_a? Hash then
          @props = @props.keys
        end

        if filter and filter.is_a? Hash then
          @filter = filter
        end

        obj = ET_Get.new(@authStub, "DataExtensionObject[#{@Name}]", @props, @filter)
        @lastRequestID = obj.request_id

        return obj
      end

      def post
        getCustomerKey
        originalProps = @props
        ## FIX THIS
        if @props.is_a? Array then
 #         multiRow = []
 #         @props.each { |currentDE|

 #           currentDE['columns'].each { |key|
 #             currentDE['Fields'] = {}
 #             currentDE['Fields']['Field'] = []
 #             currentDE['Fields']['Field'].push(key)
 #           }
 #           currentDE.delete('columns')
 #           multiRow.push(currentDE.dup)
 #         }

 #         @props = multiRow
        else
          currentFields = []
          currentProp = {}

          @props.each { |key,value|
            currentFields.push({"Name" => key, "Value" => value})
          }
          currentProp['CustomerKey'] = @CustomerKey
          currentProp['Properties'] = {}
          currentProp['Properties']['Property'] = currentFields
        end

        obj = ET_Post.new(@authStub, @obj, currentProp)
        @props = originalProps
        obj
      end

      def patch
        getCustomerKey
        currentFields = []
        currentProp = {}

        @props.each { |key,value|
          currentFields.push({"Name" => key, "Value" => value})
        }
        currentProp['CustomerKey'] = @CustomerKey
        currentProp['Properties'] = {}
        currentProp['Properties']['Property'] = currentFields

        ET_Patch.new(@authStub, @obj, currentProp)
      end
      def delete
        getCustomerKey
        currentFields = []
        currentProp = {}

        @props.each { |key,value|
          currentFields.push({"Name" => key, "Value" => value})
        }
        currentProp['CustomerKey'] = @CustomerKey
        currentProp['Keys'] = {}
        currentProp['Keys']['Key'] = currentFields

        ET_Delete.new(@authStub, @obj, currentProp)
      end

      private
      def getCustomerKey
        if @CustomerKey.nil? then
          if @CustomerKey.nil? && @Name.nil? then
            raise 'Unable to process DataExtension::Row request due to CustomerKey and Name not being defined on ET_DatExtension::row'
          else
            de = ET_DataExtension.new
            de.authStub = @authStub
            de.props = ["Name","CustomerKey"]
            de.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => @Name}
            getResponse = de.get
            if getResponse.status && (getResponse.results.length == 1) then
              @CustomerKey = getResponse.results[0][:customer_key]
            else
              raise 'Unable to process DataExtension::Row request due to unable to find DataExtension based on Name'
            end
          end
        end
      end

      def getName
        if @Name.nil? then
          if @CustomerKey.nil? && @Name.nil? then
            raise 'Unable to process DataExtension::Row request due to CustomerKey and Name not being defined on ET_DatExtension::row'
          else
            de = ET_DataExtension.new
            de.authStub = @authStub
            de.props = ["Name","CustomerKey"]
            de.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => @CustomerKey}
            getResponse = de.get
            if getResponse.status && (getResponse.results.length == 1) then
              @Name = getResponse.results[0][:name]
            else
              raise 'Unable to process DataExtension::Row request due to unable to find DataExtension based on CustomerKey'
            end
          end
        end
      end
    end
  end
=end
