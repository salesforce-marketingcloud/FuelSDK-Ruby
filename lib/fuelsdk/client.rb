module FuelSDK
  class Response
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

  class Client
    attr_accessor :debug, :access_token, :auth_token, :internal_token, :refresh_token,
      :id, :secret, :signature, :package_name, :package_folders, :parent_folders, :auth_token_expiration

    include FuelSDK::Soap
    include FuelSDK::Rest

    def jwt= encoded_jwt
      raise 'Require app signature to decode JWT' unless self.signature
      decoded_jwt = JWT.decode(encoded_jwt, self.signature, true)

      self.auth_token = decoded_jwt['request']['user']['oauthToken']
      self.internal_token = decoded_jwt['request']['user']['internalOauthToken']
      self.refresh_token = decoded_jwt['request']['user']['refreshToken']
      #@auth_token_expiration = Time.new + decoded_jwt['request']['user']['expiresIn']
	  self.package_name = decoded_jwt['request']['application']['package']
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
        self.auth_token_expiration = Time.new + response['expiresIn']
        self.refresh_token = response['refreshToken'] if response.has_key?("refreshToken")
		return true
	  else 
		return false
      end
    end

    def refresh!
      refresh true
    end

    def AddSubscriberToList(email, ids, subscriber_key = nil)
      s = FuelSDK::Subscriber.new
      s.client = self
      lists = ids.collect{|id| {'ID' => id}}
      s.properties = {"EmailAddress" => email, "Lists" => lists}
	  p s.properties 
      s.properties['SubscriberKey'] = subscriber_key if subscriber_key

      # Try to add the subscriber
      if(rsp = s.post and rsp.results.first[:error_code] == '12014')
        # subscriber already exists we need to update.
        rsp = s.patch
      end
      rsp
    end

    def CreateDataExtensions(definitions)
      de = FuelSDK::DataExtension.new
      de.client = self
      de.properties = definitions
      de.post
    end
  end
end
