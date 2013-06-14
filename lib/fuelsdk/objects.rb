module FuelSDK
  module ET_Get
    def get
      client.get id, properties, filter
    end

    def info
      client.describe id, properties, filter
    end
  end

  module ET_CUD #create, update, delete

    def post
      client.post id, properties
    end

    def put
      client.put id, properties
    end

    def delete
      client.delete id, properties
    end
  end

  class ET_BaseObject
    attr_accessor :filter, :properties, :client
    attr_reader :id

    alias props= properties= # backward compatibility
    alias authObj= client= # backward compatibility

    def id
      self.class.name.split('::').pop.split('_').pop
    end
  end

  class ET_BounceEvent < ET_BaseObject
    include ET_Get
  end

  class ET_ClickEvent < ET_BaseObject
    include ET_Get
  end

  class ET_ContentArea < ET_BaseObject
    include ET_Get
    include ET_CUD
  end

  class ET_DataFolder < ET_BaseObject
    include ET_Get
    include ET_CUD
  end

  class ET_Email < ET_BaseObject
    include ET_Get
    include ET_CUD
  end

  class ET_List < ET_BaseObject
    include ET_Get
    include ET_CUD

    class Subscriber < ET_BaseObject
      include ET_Get
      def id
        'ListSubscriber'
      end
    end
  end

  class ET_OpenEvent < ET_BaseObject
    include ET_Get
  end

  class ET_SentEvent < ET_BaseObject
    include ET_Get
  end

  class ET_Subscriber < ET_BaseObject
    include ET_Get
    include ET_CUD
  end

  class ET_UnsubEvent < ET_BaseObject
    include ET_Get
  end

end
