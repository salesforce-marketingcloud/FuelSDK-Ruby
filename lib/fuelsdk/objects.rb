module FuelSDK
  module Objects
    module Soap
      module Read
        attr_accessor :filter
        def get _id=nil
          client.soap_get _id||id, properties, filter
        end

        def info
          client.soap_describe id
        end
      end

      module CUD #create, update, delete
        def post
          client.soap_post id, properties
        end

        def patch
          client.soap_patch id, properties
        end

        def delete
          client.soap_delete id, properties
        end
      end
    end

    module Rest
      module Read
        def get
          client.rest_get id, properties
        end
      end

      module CUD
        def post
          client.rest_post id, properties
        end

        def patch
          client.rest_patch id, properties
        end

        def delete
          client.rest_delete id, properties
        end
      end
    end

    class Base
      attr_accessor :properties, :client
      attr_reader :id

      alias props= properties= # backward compatibility
      alias authStub= client= # backward compatibility

      def properties
        @properties = [@properties].compact unless @properties.kind_of? Array
        @properties
      end

      def id
        self.class.id
      end

      class << self
        def id
          self.name.split('::').pop
        end
      end
    end
  end

  class BounceEvent < Objects::Base
    include Objects::Soap::Read
  end

  class ClickEvent < Objects::Base
    include Objects::Soap::Read
  end

  class ContentArea < Objects::Base
    include Objects::Soap::Read
    include Objects::Soap::CUD
  end

  class DataFolder < Objects::Base
    include Objects::Soap::Read
    include Objects::Soap::CUD
  end

  class Folder < DataFolder
    class << self
      def id
        DataFolder.id
      end
    end
  end

  class Email < Objects::Base
    include Objects::Soap::Read
    include Objects::Soap::CUD
  end

  class List < Objects::Base
    include Objects::Soap::Read
    include Objects::Soap::CUD

    class Subscriber < Objects::Base
      include Objects::Soap::Read
      def id
        'ListSubscriber'
      end
    end
  end

  class OpenEvent < Objects::Base
    include Objects::Soap::Read
  end

  class SentEvent < Objects::Base
    include Objects::Soap::Read
  end

  class Subscriber < Objects::Base
    include Objects::Soap::Read
    include Objects::Soap::CUD
  end

  class UnsubEvent < Objects::Base
    include Objects::Soap::Read
  end

  class TriggeredSend < Objects::Base
    include Objects::Soap::Read
    include Objects::Soap::CUD
    attr_accessor :subscribers
    def id
      'TriggeredSendDefinition'
    end
    def send
      client.soap_post 'TriggeredSend', 'TriggeredSendDefinition' => properties, 'Subscribers' => subscribers
    end
  end

  class DataExtension < Objects::Base
    include Objects::Soap::Read
    include Objects::Soap::CUD
    attr_accessor :fields
    alias columns= fields= # backward compatibility


    def post
      munge_fields self.properties
      super
    end

    def patch
      munge_fields self.properties
      super
    end

    class Column < Objects::Base
      include Objects::Soap::Read
      def id
        'DataExtensionField'
      end
      def get
        if filter and filter.kind_of? Hash and \
          filter.include? 'Property' and filter['Property'] == 'CustomerKey'
          filter['Property'] = 'DataExtension.CustomerKey'
        end
        super
      end
    end

    class Row < Objects::Base
      include Objects::Soap::Read
      include Objects::Soap::CUD

      attr_accessor :name, :customer_key

      # backward compatibility
      alias Name= name=
      alias CustomerKey= customer_key=

      def id
        'DataExtensionObject'
      end

      def get
        retrieve_required

        super "#{id}[#{name}]"
      end

      def name
        unless @name
          retrieve_required
        end
        @name
      end

      def customer_key
        unless @customer_key
          retrieve_required
        end
        @customer_key
      end

      def post
        munge_properties self.properties
        super
      end

      def patch
        munge_properties self.properties
        super
      end

      private
        def munge_properties d
          d.each do |o|

            next if explicit_properties(o) && explicit_customer_key(o)

            formatted = []
            o.each do |k, v|
              formatted.concat client.format_name_value_pairs k => v
              o['Properties'] = {'Property' => formatted }
              o['CustomerKey'] = customer_key unless explicit_customer_key o
              o.delete k
            end
          end
        end

        def explicit_properties h
          h['Properties'] and h['Properties']['Property']
        end

        def explicit_customer_key h
          h['CustomerKey']
        end

        def retrieve_required
          # have to use instance variables so we don't recursivelly retrieve_required
          if !@name && !@customer_key
            raise 'Unable to process DataExtension::Row ' \
              'request due to missing CustomerKey and Name'
          end
          if !@name || !@customer_key
            filter = {
              'Property' => @name.nil? ? 'CustomerKey' : 'Name',
              'SimpleOperator' => 'equals',
              'Value' => @customer_key || @name
            }
            rsp = client.soap_get 'DataExtension', ['Name', 'CustomerKey'], filter
            if rsp.success? && rsp.results.count == 1
              self.name = rsp.results.first[:name]
              self.customer_key = rsp.results.first[:customer_key]
            else
              raise 'Unable to process DataExtension::Row'
            end
          end
        end
    end

    private

      def munge_fields d
        # maybe one day will make it smart enough to zip properties and fields if count is same?
        if d.kind_of? Array and d.count > 1 and (fields and !fields.empty?)
          # we could map the field to all DataExtensions, but lets make user be explicit.
          # if they are going to use fields attribute properties should
          # be a single DataExtension Defined in a Hash
          raise 'Unable to handle muliple DataExtension definitions and a field definition'
        end

        d.each do |de|

          if (explicit_fields(de) and (de['columns'] || de['fields'] || has_fields)) or
            (de['columns'] and (de['fields'] || has_fields)) or
            (de['fields'] and has_fields)
            raise 'Fields are defined in too many ways. Please only define once.' # ahhh what, to do...
          end

          # let users who chose, to define fields explicitly within the hash definition
          next if explicit_fields de

          de['Fields'] = {'Field' => de['columns'] || de['fields'] || fields}
          # sanitize
          de.delete 'columns'
          de.delete 'fields'
          raise 'DataExtension needs atleast one field.' unless de['Fields']['Field']
        end
      end

      def explicit_fields h
        h['Fields'] and h['Fields']['Field']
      end

      def has_fields
        fields and !fields.empty?
      end
  end

  class Campaign < Objects::Base
    include Objects::Rest::Read
    include Objects::Rest::CUD

    def properties
      @properties ||= {}
      @properties.merge! 'id' => '' unless @properties.include? 'id'
      @properties
    end

    def id
      "https://www.exacttargetapis.com/hub/v1/campaigns/%{id}"
    end

    class Asset < Objects::Base
      include Objects::Rest::Read
      include Objects::Rest::CUD

      def properties
        @properties ||= {}
        @properties.merge! 'assetId' => '' unless @properties.include? 'assetId'
        @properties
      end

      def id
        'https://www.exacttargetapis.com/hub/v1/campaigns/%{id}/assets/%{assetId}'
      end
    end
  end
end
