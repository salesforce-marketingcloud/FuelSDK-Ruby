module MarketingCloudSDK
  class ExactTargetEndpoints
    def self.config
      YAML.load_file(
        File.join('config', 'endpoints.yml')
      )
    end

    def self.base_api_url
      @base_api_url ||= config['base_api_url']
    end

    def self.request_token_url
      @request_token_url ||= config['request_token_url']
    end

    def self.soap_wsdl_endpoint
      @soap_wsdl_endpoint ||= config['soap_wsdl_endpoint']
    end

    def self.soap_service_endpoint
      @soap_service_endpoint ||= config['soap_service_endpoint']
    end
  end
end
