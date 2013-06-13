require 'savon'
module FuelSDK
  class SoapResponse
  end

  module Soap
    attr_accessor :wsdl, :debug, :internal_token

    include FuelSDK::Targeting


    def mode
      "soap"
    end

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

    def client
      self.refresh unless internal_token
      @client ||= Savon.client(
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

    def describe object_type
      rsp = client.call(:describe, :message => {
        'DescribeRequests' => {
          'ObjectDefinitionRequest' => {
            'ObjectType' => object_type
          }
        }
      })
    end
  end
end
