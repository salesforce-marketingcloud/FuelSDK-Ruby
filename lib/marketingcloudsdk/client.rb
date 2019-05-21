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

require 'securerandom'
module MarketingCloudSDK
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
		:id, :secret, :signature, :base_api_url, :package_name, :package_folders, :parent_folders, :auth_token_expiration,
		:request_token_url, :soap_endpoint, :use_oAuth2_authentication, :account_id, :scope

	include MarketingCloudSDK::Soap
	include MarketingCloudSDK::Rest

		def jwt= encoded_jwt
			raise 'Require app signature to decode JWT' unless self.signature
			decoded_jwt = JWT.decode(encoded_jwt, self.signature, true)

			self.auth_token = decoded_jwt['request']['user']['oauthToken']
			self.internal_token = decoded_jwt['request']['user']['internalOauthToken']
			self.refresh_token = decoded_jwt['request']['user']['refreshToken']
			self.auth_token_expiration = Time.new + decoded_jwt['request']['user']['expiresIn']
			self.package_name = decoded_jwt['request']['application']['package']
		end

		def initialize(params={}, debug=false)
			@refresh_mutex = Mutex.new
			self.debug = debug
			client_config = params['client']
			if client_config
        self.id = client_config["id"]
        self.secret = client_config["secret"]
        self.signature = client_config["signature"]
				self.base_api_url = !(client_config["base_api_url"].to_s.strip.empty?) ? client_config["base_api_url"] : 'https://www.exacttargetapis.com'
				self.request_token_url = client_config["request_token_url"]
				self.soap_endpoint = client_config["soap_endpoint"]
				self.use_oAuth2_authentication = client_config["use_oAuth2_authentication"]
				self.account_id = client_config["account_id"]
				self.scope = client_config["scope"]
			end

			# Set a default value in case no 'client' params is sent
			if (!self.base_api_url)
				self.base_api_url =  'https://www.exacttargetapis.com'
			end

			if (self.request_token_url.to_s.strip.empty?)
				if(use_oAuth2_authentication == true)
					raise 'request_token_url (Auth TSE) is mandatory when using OAuth2 authentication'
				else
					self.request_token_url =  'https://auth.exacttargetapis.com/v1/requestToken'
				end
			end

			self.jwt = params['jwt'] if params['jwt']
			self.refresh_token = params['refresh_token'] if params['refresh_token']

			self.wsdl = params["defaultwsdl"] if params["defaultwsdl"]

			self.refresh
		end

		def refresh force=false
			@refresh_mutex.synchronize do
				raise 'Require Client Id and Client Secret to refresh tokens' unless (id && secret)

				if (self.use_oAuth2_authentication == true)
					self.refreshWithOAuth2(force)
					return
				end

				#If we don't already have a token or the token expires within 5 min(300 seconds)
				if (self.access_token.nil? || Time.new + 300 > self.auth_token_expiration || force) then
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
				response = post(request_token_url, options)
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
		end

	def refreshWithOAuth2 force=false
		raise 'Require Client Id and Client Secret to refresh tokens' unless (id && secret)
		#If we don't already have a token or the token expires within 5 min(300 seconds)
		if (self.access_token.nil? || Time.new + 300 > self.auth_token_expiration || force) then
			payload = Hash.new.tap do |h|
				h['client_id']= id
				h['client_secret'] = secret
				h['grant_type'] = 'client_credentials'

				if (not self.account_id.to_s.strip.empty?)then
					h['account_id'] = account_id
				end

				if (not self.scope.to_s.strip.empty?)then
					h['scope'] = scope
				end
			end

			options = Hash.new.tap do |h|
				h['data'] = payload
				h['content_type'] = 'application/json'
			end

			self.request_token_url += '/v2/token'

			response = post(request_token_url, options)
			raise "Unable to refresh token: #{response['message']}" unless response.has_key?('access_token')

			self.access_token = response['access_token']
			self.auth_token_expiration = Time.new + response['expires_in']
			self.soap_endpoint = response['soap_instance_url'] + 'service.asmx'
			self.base_api_url = response['rest_instance_url']
			return true
		else
			return false
		end
	end

		def refresh!
			refresh true
		end

		def AddSubscriberToList(email, ids, subscriber_key = nil)
			s = MarketingCloudSDK::Subscriber.new
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
			de = MarketingCloudSDK::DataExtension.new
			de.client = self
			de.properties = definitions
			de.post
		end
		def SendTriggeredSends(arrayOfTriggeredRecords)
			sendTS = ET_TriggeredSend.new
			sendTS.authStub = self
			
			sendTS.properties = arrayOfTriggeredRecords
			sendResponse = sendTS.send
			
			return sendResponse
		end
		def SendEmailToList(emailID, listID, sendClassificationCustomerKey)
			email = ET_Email::SendDefinition.new 
			email.properties = {"Name"=>SecureRandom.uuid, "CustomerKey"=>SecureRandom.uuid, "Description"=>"Created with RubySDK"} 
			email.properties["SendClassification"] = {"CustomerKey"=>sendClassificationCustomerKey}
			email.properties["SendDefinitionList"] = {"List"=> {"ID"=>listID}, "DataSourceTypeID"=>"List"}
			email.properties["Email"] = {"ID"=>emailID}
			email.authStub = self
			result = email.post
			if result.status then 
				sendresult = email.send 
				if sendresult.status then 
					deleteresult = email.delete
					return sendresult
				else 
					raise "Unable to send using send definition due to: #{result.results[0][:status_message]}"
				end 
			else
				raise "Unable to create send definition due to: #{result.results[0][:status_message]}"
			end 
		end 
			
		def SendEmailToDataExtension(emailID, sendableDataExtensionCustomerKey, sendClassificationCustomerKey)
			email = ET_Email::SendDefinition.new 
			email.properties = {"Name"=>SecureRandom.uuid, "CustomerKey"=>SecureRandom.uuid, "Description"=>"Created with RubySDK"} 
			email.properties["SendClassification"] = {"CustomerKey"=> sendClassificationCustomerKey}
			email.properties["SendDefinitionList"] = {"CustomerKey"=> sendableDataExtensionCustomerKey, "DataSourceTypeID"=>"CustomObject"}
			email.properties["Email"] = {"ID"=>emailID}
			email.authStub = self
			result = email.post
			if result.status then 
				sendresult = email.send 
				if sendresult.status then 
					deleteresult = email.delete
					return sendresult
				else 
					raise "Unable to send using send definition due to: #{result.results[0][:status_message]}"
				end 
			else
				raise "Unable to create send definition due to: #{result.results[0][:status_message]}"
			end 
		end
		def CreateAndStartListImport(listId,fileName)
			import = ET_Import.new 
			import.authStub = self
			import.properties = {"Name"=> "SDK Generated Import #{DateTime.now.to_s}"}
			import.properties["CustomerKey"] = SecureRandom.uuid
			import.properties["Description"] = "SDK Generated Import"
			import.properties["AllowErrors"] = "true"
			import.properties["DestinationObject"] = {"ID"=>listId}
			import.properties["FieldMappingType"] = "InferFromColumnHeadings"
			import.properties["FileSpec"] = fileName
			import.properties["FileType"] = "CSV"
			import.properties["RetrieveFileTransferLocation"] = {"CustomerKey"=>"ExactTarget Enhanced FTP"}
			import.properties["UpdateType"] = "AddAndUpdate"
			result = import.post
			
			if result.status then 
				return import.start 
			else
				raise "Unable to create import definition due to: #{result.results[0][:status_message]}"
			end 
		end 
			
		def CreateAndStartDataExtensionImport(dataExtensionCustomerKey, fileName, overwrite)
			import = ET_Import.new 
			import.authStub = self
			import.properties = {"Name"=> "SDK Generated Import #{DateTime.now.to_s}"}
			import.properties["CustomerKey"] = SecureRandom.uuid
			import.properties["Description"] = "SDK Generated Import"
			import.properties["AllowErrors"] = "true"
			import.properties["DestinationObject"] = {"CustomerKey"=>dataExtensionCustomerKey}
			import.properties["FieldMappingType"] = "InferFromColumnHeadings"
			import.properties["FileSpec"] = fileName
			import.properties["FileType"] = "CSV"
			import.properties["RetrieveFileTransferLocation"] = {"CustomerKey"=>"ExactTarget Enhanced FTP"}
			if overwrite then
				import.properties["UpdateType"] = "Overwrite"
			else 
				import.properties["UpdateType"] = "AddAndUpdate"
			end 
			result = import.post
			
			if result.status then 
				return import.start 
			else
				raise "Unable to create import definition due to: #{result.results[0][:status_message]}"
			end 
		end 
			
		def CreateProfileAttributes(allAttributes)
			attrs = ET_ProfileAttribute.new 
			attrs.authStub = self
			attrs.properties = allAttributes
			return attrs.post
		end
		
		def CreateContentAreas(arrayOfContentAreas)
			postC = ET_ContentArea.new
			postC.authStub = self
			postC.properties = arrayOfContentAreas
			sendResponse = postC.post			
			return sendResponse
		end
	end
end
