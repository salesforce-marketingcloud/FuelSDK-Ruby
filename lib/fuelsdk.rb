require "fuelsdk/version"

require 'rubygems'
require 'date'
require 'jwt'

module FuelSDK
  require 'fuelsdk/utils'
  autoload :HTTPRequest, 'fuelsdk/http_request'
  autoload :Targeting, 'fuelsdk/targeting'
  autoload :Soap, 'fuelsdk/soap'
  autoload :Rest, 'fuelsdk/rest'
  require 'fuelsdk/client'
  require 'fuelsdk/objects'
end

# backwards compatability
ET_Client = FuelSDK::Client
ET_BounceEvent = FuelSDK::BounceEvent
ET_ClickEvent = FuelSDK::ClickEvent
ET_ContentArea = FuelSDK::ContentArea
ET_DataExtension = FuelSDK::DataExtension
ET_DataFolder = FuelSDK::DataFolder
ET_Folder = FuelSDK::Folder
ET_Email = FuelSDK::Email
ET_List = FuelSDK::List
ET_OpenEvent = FuelSDK::OpenEvent
ET_SentEvent = FuelSDK::SentEvent
ET_Subscriber = FuelSDK::Subscriber
ET_UnsubEvent = FuelSDK::UnsubEvent
ET_TriggeredSend = FuelSDK::TriggeredSend
ET_Campaign = FuelSDK::Campaign
ET_Get = FuelSDK::Get
