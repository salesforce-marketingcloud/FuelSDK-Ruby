module FuelSDK
  module ET_SoapGet
    def get
      client.soap_get id, properties, filter
    end

    def info
      client.soap_describe id
    end
  end

  module ET_SoapCUD #create, update, delete
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

  module ET_RestGet
    def get
      client.rest_get id, properties
    end
  end

  module ET_RestCUD
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

  class ET_Base
    attr_accessor :filter, :properties, :client
    attr_reader :id

    alias props= properties= # backward compatibility
    alias authStub= client= # backward compatibility

    def id
      self.class.name.split('::').pop.split('_').pop
    end
  end

  class ET_BounceEvent < ET_Base
    include ET_SoapGet
  end

  class ET_ClickEvent < ET_Base
    include ET_SoapGet
  end

  class ET_ContentArea < ET_Base
    include ET_SoapGet
    include ET_SoapCUD
  end

  class ET_Folder < ET_Base
    include ET_SoapGet
    include ET_SoapCUD
    def id
      'DataFolder'
    end
  end

  class ET_Email < ET_Base
    include ET_SoapGet
    include ET_SoapCUD
  end

  class ET_List < ET_Base
    include ET_SoapGet
    include ET_SoapCUD

    class Subscriber < ET_Base
      include ET_SoapGet
      def id
        'ListSubscriber'
      end
    end
  end

  class ET_OpenEvent < ET_Base
    include ET_SoapGet
  end

  class ET_SentEvent < ET_Base
    include ET_SoapGet
  end

  class ET_Subscriber < ET_Base
    include ET_SoapGet
    include ET_SoapCUD
  end

  class ET_UnsubEvent < ET_Base
    include ET_SoapGet
  end

  class ET_TriggeredSend < ET_Base
    attr_accessor :subscribers
    include ET_SoapGet
    include ET_SoapCUD
    def id
      'TriggeredSendDefinition'
    end
    def send
      client.soap_post 'TriggeredSend', 'TriggeredSendDefinition' => properties, 'Subscribers' => subscribers
    end
  end

  class ET_Campaign < ET_Base
    include ET_RestGet
    include ET_RestCUD


    def properties
      @properties ||= {}
      @properties.merge! 'id' => '' unless @properties.include? 'id'
      @properties
    end

    def id
      "https://www.exacttargetapis.com/hub/v1/campaigns/%{id}"
    end

    class Asset < ET_Base
      include ET_RestGet
      include ET_RestCUD

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
