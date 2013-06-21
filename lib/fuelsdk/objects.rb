module FuelSDK
  module Objects
    module SoapRead
      def get
        client.soap_get id, properties, filter
      end

      def info
        client.soap_describe id
      end
    end

    module SoapCUD #create, update, delete
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

    module RestRead
      def get
        client.rest_get id, properties
      end
    end

    module RestCUD
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

    class Base
      attr_accessor :filter, :properties, :client
      attr_reader :id

      alias props= properties= # backward compatibility
      alias authStub= client= # backward compatibility

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
    include Objects::SoapRead
  end

  class ClickEvent < Objects::Base
    include Objects::SoapRead
  end

  class ContentArea < Objects::Base
    include Objects::SoapRead
    include Objects::SoapCUD
  end

  class DataFolder < Objects::Base
    include Objects::SoapRead
    include Objects::SoapCUD
  end

  class Folder < DataFolder
    class << self
      def id
        DataFolder.id
      end
    end
  end

  class Email < Objects::Base
    include Objects::SoapRead
    include Objects::SoapCUD
  end

  class List < Objects::Base
    include Objects::SoapRead
    include Objects::SoapCUD

    class Subscriber < Objects::Base
      include Objects::SoapRead
      def id
        'ListSubscriber'
      end
    end
  end

  class OpenEvent < Objects::Base
    include Objects::SoapRead
  end

  class SentEvent < Objects::Base
    include Objects::SoapRead
  end

  class Subscriber < Objects::Base
    include Objects::SoapRead
    include Objects::SoapCUD
  end

  class UnsubEvent < Objects::Base
    include Objects::SoapRead
  end

  class TriggeredSend < Objects::Base
    attr_accessor :subscribers
    include Objects::SoapRead
    include Objects::SoapCUD
    def id
      'TriggeredSendDefinition'
    end
    def send
      client.soap_post 'TriggeredSend', 'TriggeredSendDefinition' => properties, 'Subscribers' => subscribers
    end
  end

  class Campaign < Objects::Base
    include Objects::RestRead
    include Objects::RestCUD

    def properties
      @properties ||= {}
      @properties.merge! 'id' => '' unless @properties.include? 'id'
      @properties
    end

    def id
      "https://www.exacttargetapis.com/hub/v1/campaigns/%{id}"
    end

    class Asset < Objects::Base
      include Objects::RestRead
      include Objects::RestCUD

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
