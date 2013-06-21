module FuelSDK
  class ET_Response
    # not doing accessor so user, can't update these values from response.
    # You will see in the code some of these
    # items are being updated via back doors and such.
    attr_reader :code, :message, :results, :request_id, :body, :raw

    # some defaults
    def success
      @success ||= false
    end
    alias :success? :success
    alias :status :success # backward compatibility

    def more
      @more ||= false
    end
    alias :more? :more

    def initialize raw, client
      @client = client # keep connection with client in case we request more
      @results = []
      @raw = raw
      unpack raw
    rescue => ex # all else fails return raw
      puts ex.message
      raw
    end

    def continue
      raise NotImplementedError
    end

    private
      def unpack raw
        raise NotImplementedError
      end
  end

  class ET_Client
    attr_accessor :debug, :access_token, :auth_token, :internal_token, :refresh_token,
      :id, :secret, :signature

    include FuelSDK::Soap
    include FuelSDK::Rest

    def jwt= encoded_jwt
      raise 'Require app signature to decode JWT' unless self.signature
      decoded_jwt = JWT.decode(encoded_jwt, self.signature, true)

      self.auth_token = decoded_jwt['request']['user']['oauthToken']
      self.internal_token = decoded_jwt['request']['user']['internalOauthToken']
      self.refresh_token = decoded_jwt['request']['user']['refreshToken']
      #@authTokenExpiration = Time.new + decoded_jwt['request']['user']['expiresIn']
    end

    def initialize(params={}, debug=false)
      self.debug = debug
      client_config = params['client']
      if client_config
        self.id = client_config["id"]
        self.secret = client_config["secret"]
        self.signature = client_config["signature"]
      end

      self.jwt = params['jwt'] if params['jwt']
      self.refresh_token = params['refresh_token'] if params['refresh_token']

      self.wsdl = params["defaultwsdl"] if params["defaultwsdl"]
    end

    def refresh force=false
      raise 'Require Client Id and Client Secret to refresh tokens' unless (id && secret)

      if (self.access_token.nil? || force)
        payload = Hash.new.tap do |h|
          h['clientId']= id
          h['clientSecret'] = secret
          h['refreshToken'] = refresh_token if refresh_token
          h['accessType'] = 'offline'
        end

        options = Hash.new.tap do |h|
          h['data'] = payload
          h['content_type'] = 'application/json'
          h['params'] = {'legacy' => 1}
        end

        response = post("https://auth.exacttargetapis.com/v1/requestToken", options)
        raise "Unable to refresh token: #{response['message']}" unless response.has_key?('accessToken')

        self.access_token = response['accessToken']
        self.internal_token = response['legacyToken']
        #@authTokenExpiration = Time.new + tokenResponse['expiresIn']
        self.refresh_token = response['refreshToken'] if response.has_key?("refreshToken")
      end
    end

    def refresh!
      refresh true
    end

    #def AddSubscriberToList(emailAddress, listIDs, subscriberKey = nil)
    #  newSub = FuelSDK::ET_Subscriber.new
    #  newSub.authStub = self
    #  lists = []

    #  listIDs.each{ |p|
    #    lists.push({"ID"=> p})
    #  }

    #  newSub.props = {"EmailAddress" => emailAddress, "Lists" => lists}
    #  if !subscriberKey.nil? then
    #    newSub.props['SubscriberKey']  = subscriberKey;
    #  end

    #  # Try to add the subscriber
    #  postResponse = newSub.post

    #  if postResponse.status == false then
    #    # If the subscriber already exists in the account then we need to do an update.
    #    # Update Subscriber On List
    #    if postResponse.results[0][:error_code] == "12014" then
    #      patchResponse = newSub.patch
    #      return patchResponse
    #    end
    #  end
    #  return postResponse
    #end

    #def CreateDataExtensions(dataExtensionDefinitions)
    #  newDEs = FuelSDK::ET_DataExtension.new
    #  newDEs.authStub = self

    #  newDEs.props = dataExtensionDefinitions
    #  postResponse = newDEs.post

    #  return postResponse
    #end
  end
end
