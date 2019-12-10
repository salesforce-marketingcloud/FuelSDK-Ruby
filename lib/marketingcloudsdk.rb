=begin
Copyright (c) 2013 ExactTarget, Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 

following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the 

following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 

following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote 

products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 

INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 

DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 

SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 

SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 

WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 

USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end

require "marketingcloudsdk/version"

require 'rubygems'
require 'date'
require 'jwt'

module MarketingCloudSDK
  require 'marketingcloudsdk/utils'
  autoload :HTTPRequest, 'marketingcloudsdk/http_request'
  autoload :Targeting, 'marketingcloudsdk/targeting'
  autoload :Soap, 'marketingcloudsdk/soap'
  autoload :Rest, 'marketingcloudsdk/rest'
  require 'marketingcloudsdk/client'
  require 'marketingcloudsdk/objects'
end

# backwards compatability
ET_Client = MarketingCloudSDK::Client
ET_BounceEvent = MarketingCloudSDK::BounceEvent
ET_ClickEvent = MarketingCloudSDK::ClickEvent
ET_ContentArea = MarketingCloudSDK::ContentArea
ET_DataExtension = MarketingCloudSDK::DataExtension
ET_DataFolder = MarketingCloudSDK::DataFolder
ET_Folder = MarketingCloudSDK::Folder
ET_Email = MarketingCloudSDK::Email
ET_List = MarketingCloudSDK::List
ET_OpenEvent = MarketingCloudSDK::OpenEvent
ET_SentEvent = MarketingCloudSDK::SentEvent
ET_Subscriber = MarketingCloudSDK::Subscriber
ET_UnsubEvent = MarketingCloudSDK::UnsubEvent
ET_TriggeredSend = MarketingCloudSDK::TriggeredSend
ET_Campaign = MarketingCloudSDK::Campaign
ET_Get = MarketingCloudSDK::Get
ET_Post = MarketingCloudSDK::Post
ET_Delete = MarketingCloudSDK::Delete
ET_Patch = MarketingCloudSDK::Patch
ET_ProfileAttribute = MarketingCloudSDK::ProfileAttribute
ET_Import = MarketingCloudSDK::Import
