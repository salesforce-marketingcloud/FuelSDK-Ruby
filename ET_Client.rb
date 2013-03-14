require 'rubygems'
require 'open-uri'
require 'savon'
require 'date'
require 'json'
require 'yaml'
require 'jwt'

class ET_Constructor
	attr_accessor :status, :code, :message, :results, :request_id, :moreResults
		
	def initialize(response = nil, rest = false)
		@results = []
		if !response.nil? && !rest then 
			envelope = response.hash[:envelope]
			@@body = envelope[:body]							
				
			if ((!response.soap_fault?) or (!response.http_error?)) then
				@code = response.http.code
				@status = true
			elsif (response.soap_fault?) then
				@code = response.http.code
				@message = @@body[:fault][:faultstring]
				@status = false
			elsif (response.http_error?) then
				@code = response.http.code
				@status = false         
			end
		elsif 			
			@code = response.code
			@status = true
			if @code != "200" then
				@status = false 
			end  
						
			begin
			  @results = JSON.parse(response.body)			  
			rescue 
			  @message = response.body
			end
			
			
		end 
	end
end

class ET_CreateWSDL
  
  def initialize(path)
    # Get the header info for the correct wsdl
	response = HTTPI.head(@wsdl)
	if response and (response.code >= 200 and response.code <= 400) then
		header = response.headers
		# Check when the WSDL was last modified
		modifiedTime = Date.parse(header['last-modified'])
		p = path + '/ExactTargetWSDL.xml'
		# Check if a local file already exists
		if (File.file?(p) and File.readable?(p) and !File.zero?(p)) then
			createdTime = File.new(p).mtime.to_date
			
			# Check if the locally created WSDL older than the production WSDL
			if createdTime < modifiedTime then
				createIt = true
			else
				createIt = false
			end
		else
			createIt = true
		end
		
		if createIt then
			res = open(@wsdl).read
			File.open(p, 'w+') { |f|
				f.write(res)
			}
		end
		@status = response.code
	else
		@status = response.code
	end
 
  end
end

class ET_Client < ET_CreateWSDL
	attr_accessor :auth, :ready, :status, :debug, :authToken
	attr_reader :authTokenExpiration, :internalAuthToken, :wsdlLoc, :clientId, :clientSecret, :soapHeader, :authObj, :path, :appsignature, :stackID, :refreshKey 

	def initialize(getWSDL = nil, debug = nil, params = nil)	
		config = YAML.load_file("config.yaml")			
		@clientId = config["clientid"]
		@clientSecret = config["clientsecret"]			
		@appsignature = config["appsignature"]		
		@wsdl = config["defaultwsdl"]
		@debug = false

		if debug then
			@debug = debug
		end
		
		if !getWSDL then
			getWSDL = true
		end
		
		begin		
			@path = File.dirname(__FILE__)
			
			#make a new WSDL
			if getWSDL then
				super(@path)
			end				
			
			if params && params.has_key?("jwt") then			
				jwt = JWT.decode(params["jwt"], nil, false);
				@authToken = jwt['request']['user']['oauthToken']
				@authTokenExpiration = Time.new + jwt['request']['user']['expiresIn']
				@internalAuthToken = jwt['request']['user']['internalOauthToken']
				@refreshKey = jwt['request']['user']['refreshToken']

				self.determineStack
				
				@authObj = {'oAuth' => {'oAuthToken' => @internalAuthToken}}			
				@authObj[:attributes!] = { 'oAuth' => { 'xmlns' => 'http://exacttarget.com' }}						
				
				myWSDL = File.read(@path + '/ExactTargetWSDL.xml')
				@auth = Savon.client(soap_header: @authObj, wsdl: myWSDL, endpoint: @endpoint, wsse_auth: ["*", "*"],raise_errors: false, log: @debug, open_timeout: 180, read_timeout: 180) 				
			else 				
				self.refreshToken	
			end 																				
												
			self.debug = @debug					
			
		rescue
			raise 
		end		
		
		if ((@auth.operations.length > 0) and (@status >= 200 and @status <= 400)) then
			@ready = true
		else
			@ready = false
		end
	end
	
	def debug=(value)
		@debug = value
	end
		
	def refreshToken(force = nil)
		#If we don't already have a token or the token expires within 5 min(300 seconds), get one
		if ((@authToken.nil? || Time.new + 300 > @authTokenExpiration) || force) then 
			begin
			uri = URI.parse("https://auth.exacttargetapis.com/v1/requestToken?legacy=1")
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			request = Net::HTTP::Post.new(uri.request_uri)
			jsonPayload = {'clientId' => @clientId, 'clientSecret' => @clientSecret}
			
			#Pass in the refreshKey if we have it 
			if @refreshKey then
				jsonPayload['refreshToken'] = @refreshKey
			end 
			
			request.body = jsonPayload.to_json			
			request.add_field "Content-Type", "application/json"
			tokenResponse = JSON.parse(http.request(request).body)				
			
			if !tokenResponse.has_key?('accessToken') then 
				raise 'Unable to validate App Keys(ClientID/ClientSecret) provided: ' + http.request(request).body 
			end 
			
			@authToken = tokenResponse['accessToken']
			@authTokenExpiration = Time.new + tokenResponse['expiresIn']
			@internalAuthToken = tokenResponse['legacyToken']
			if tokenResponse.has_key?("refreshToken") then
				@refreshKey = tokenResponse['refreshToken']
			end					
			
			if @endpoint.nil? then 
				self.determineStack
			end 
			
			@authObj = {'oAuth' => {'oAuthToken' => @internalAuthToken}}			
			@authObj[:attributes!] = { 'oAuth' => { 'xmlns' => 'http://exacttarget.com' }}						
			
			myWSDL = File.read(@path + '/ExactTargetWSDL.xml')
			@auth = Savon.client(soap_header: @authObj, 
				wsdl: myWSDL, 
				endpoint: @endpoint, 
				wsse_auth: ["*", "*"],
				raise_errors: false, 
				log: @debug) 
				

			rescue Exception => e
				raise 'Unable to validate App Keys(ClientID/ClientSecret) provided: ' + e.message  
			end
		end 
	end
	
	def AddSubscriberToList(emailAddress, listIDs, subscriberKey = nil)		
		newSub = ET_Subscriber.new 
		newSub.authStub = self
		lists = []
		
		listIDs.each{ |p|
			lists.push({"ID"=> p})			
		}
		
		newSub.props = {"EmailAddress" => emailAddress, "Lists" => lists}
		if !subscriberKey.nil? then
			newSub.props['SubscriberKey']  = subscriberKey;
		end
		
		# Try to add the subscriber
		postResponse = newSub.post
		
		if postResponse.status == false then 
			# If the subscriber already exists in the account then we need to do an update.
			# Update Subscriber On List 
			if postResponse.results[0][:error_code] == "12014" then 	
				patchResponse = newSub.patch
				return patchResponse
			end
		end 
		return postResponse
	end 
	
	def CreateDataExtensions(dataExtensionDefinitions)		
		newDEs = ET_DataExtension.new 
		newDEs.authStub = self
				
		newDEs.props = dataExtensionDefinitions						
		postResponse = newDEs.post		
		
		return postResponse
	end 
	
	
	protected 
	def determineStack()		
		begin
			uri = URI.parse("https://www.exacttargetapis.com/platform/v1/endpoints/soap?access_token=" + @authToken)
			http = Net::HTTP.new(uri.host, uri.port)

			http.use_ssl = true
			
			request = Net::HTTP::Get.new(uri.request_uri)		
					
			contextResponse = JSON.parse(http.request(request).body)
			@endpoint = contextResponse['url']

		rescue Exception => e
			raise 'Unable to determine stack using /platform/v1/tokenContext: ' + e.message  
		end
	end	
end

class ET_Describe < ET_Constructor
	def initialize(authStub = nil, objType = nil)
		begin
			authStub.refreshToken
			response = authStub.auth.call(:describe, :message => {
						'DescribeRequests' => 
							{'ObjectDefinitionRequest' => 
								{'ObjectType' => objType}
						}
					})				
		ensure
			super(response)
			
			if @status then
				objDef = @@body[:definition_response_msg][:object_definition]
				
				if objDef then
					s = true
				else
					s = false
				end		
				@overallStatus = s
				@results = @@body[:definition_response_msg][:object_definition][:properties]
			end
		end
	end
end

class ET_Post < ET_Constructor
	def initialize(authStub, objType, props = nil)
	@results = []
		
	begin
		authStub.refreshToken
		if props.is_a? Array then 
			obj = {
				'Objects' => [],
				:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
			}
			props.each{ |p|
				obj['Objects'] << p 
			}
		else
			obj = {
				'Objects' => props,
				:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
			}
		end

		response = authStub.auth.call(:create, :message => obj)			
			
	ensure 
		super(response)				
			if @status then
				if @@body[:create_response][:overall_status] != "OK"				
					@status = false
				end 
				#@results = @@body[:create_response][:results]
				if !@@body[:create_response][:results].nil? then
					if !@@body[:create_response][:results].is_a? Hash then
						@results = @results + @@body[:create_response][:results]
					else 
						@results.push(@@body[:create_response][:results])
					end
				end				
			end			
		end
	end
end

class ET_Delete < ET_Constructor

	def initialize(authStub, objType, props = nil)
	@results = []
	begin
		authStub.refreshToken
		if props.is_a? Array then 
			obj = {
				'Objects' => [],
				:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
			}
			props.each{ |p|
				obj['Objects'] << p 
			}
		else
			obj = {
				'Objects' => props,
				:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
			}
		end
		
		response = authStub.auth.call(:delete, :message => obj)		
	ensure 
		super(response)				
			if @status then
				if @@body[:delete_response][:overall_status] != "OK"				
					@status = false
				end 			
				if !@@body[:delete_response][:results].is_a? Hash then
					@results = @results + @@body[:delete_response][:results]
				else 
					@results.push(@@body[:delete_response][:results])
				end				
			end
		end
	end
end

class ET_Patch < ET_Constructor
	def initialize(authStub, objType, props = nil)
	@results = []
	begin
		authStub.refreshToken
		if props.is_a? Array then 
			obj = {
				'Objects' => [],
				:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
			}
			props.each{ |p|
				obj['Objects'] << p 
			 }
		else
			obj = {
				'Objects' => props,
				:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
			}
		end
		
		response = authStub.auth.call(:update, :message => obj)	
			
	ensure 
		super(response)				
			if @status then
				if @@body[:update_response][:overall_status] != "OK"				
					@status = false
				end 
				if !@@body[:update_response][:results].is_a? Hash then
					@results = @results + @@body[:update_response][:results]
				else 
					@results.push(@@body[:update_response][:results])
				end						
			end
		end
	end
end

class ET_Continue < ET_Constructor
	def initialize(authStub, request_id)
		@results = []
		authStub.refreshToken	
		obj = {'ContinueRequest' => request_id}		
		response = authStub.auth.call(:retrieve, :message => {'RetrieveRequest' => obj})					

		super(response)

		if @status then
			if @@body[:retrieve_response_msg][:overall_status] != "OK" && @@body[:retrieve_response_msg][:overall_status] != "MoreDataAvailable" then
				@status = false	
				@message = @@body[:retrieve_response_msg][:overall_status]							
			end 	
				
			@moreResults = false				
			if @@body[:retrieve_response_msg][:overall_status] == "MoreDataAvailable" then
				@moreResults = true				 						
			end 	

			if (!@@body[:retrieve_response_msg][:results].is_a? Hash) && (!@@body[:retrieve_response_msg][:results].nil?) then
				@results = @results + @@body[:retrieve_response_msg][:results]
			elsif  (!@@body[:retrieve_response_msg][:results].nil?)
				@results.push(@@body[:retrieve_response_msg][:results])
			end				
			
			# Store the Last Request ID for use with continue
			@request_id = @@body[:retrieve_response_msg][:request_id]			
		end
	end
end

class ET_Get < ET_Constructor
	def initialize(authStub, objType, props = nil, filter = nil)
		@results = []			
		authStub.refreshToken
		if !props then
			resp = ET_Describe.new(authStub, objType)
			if resp then
				props = []
				resp.results.map { |p|
					if p[:is_retrievable] then
						props << p[:name]
					end
				}
			end
		end
		
		# If the properties is a hash, then we just want to use the keys
		if props.is_a? Hash then 
			obj = {'ObjectType' => objType,'Properties' => props.keys}
		else 
			obj = {'ObjectType' => objType,'Properties' => props}
		end		

		if filter then
			obj['Filter'] = filter
			obj[:attributes!] = { 'Filter' => { 'xsi:type' => 'tns:SimpleFilterPart' } }
		end
		
		response = authStub.auth.call(:retrieve, :message => {
				'RetrieveRequest' => obj
				})					

		super(response)

		if @status then
			if @@body[:retrieve_response_msg][:overall_status] != "OK" && @@body[:retrieve_response_msg][:overall_status] != "MoreDataAvailable" then
				@status = false	
				@message = @@body[:retrieve_response_msg][:overall_status]							
			end 	
				
			@moreResults = false				
			if @@body[:retrieve_response_msg][:overall_status] == "MoreDataAvailable" then
				@moreResults = true				 						
			end 	

			if (!@@body[:retrieve_response_msg][:results].is_a? Hash) && (!@@body[:retrieve_response_msg][:results].nil?) then
				@results = @results + @@body[:retrieve_response_msg][:results]
			elsif  (!@@body[:retrieve_response_msg][:results].nil?)
				@results.push(@@body[:retrieve_response_msg][:results])
			end				
			
			# Store the Last Request ID for use with continue
			@request_id = @@body[:retrieve_response_msg][:request_id]			
		end
	end
end

class ET_BaseObject
	attr_accessor :authStub, :props
	attr_reader :obj, :lastRequestID, :endpoint
	
	def initialize
		@authStub = nil
		@props = nil
		@filter = nil
		@lastRequestID = nil
		@endpoint = nil
	end
end

class ET_GetSupport < ET_BaseObject
	attr_accessor :filter
	
	def initialize
		super
	end
	
	def get(props = nil, filter = nil)
		if props and props.is_a? Array then
			@props = props
		end
		
		if @props and @props.is_a? Hash then
			@props = @props.keys
		end

		if filter and filter.is_a? Hash then
			@filter = filter
		end
		obj = ET_Get.new(@authStub, @obj, @props, @filter)
		
		@lastRequestID = obj.request_id
		
		return obj
	end		
	
	def info()
		obj = ET_Describe.new(@authStub, @obj)
	end	
	
	def getMoreResults()
		obj = ET_Continue.new(@authStub, @lastRequestID)
	end		
end

class ET_CUDSupport < ET_GetSupport
	
	def initialize
		super
	end
		
	def post()			
		if props and props.is_a? Hash then
			@props = props
		end
		
		if @extProps then
			@extProps.each { |key, value|
				@props[key.capitalize] = value
			}
		end
		
		obj = ET_Post.new(@authStub, @obj, @props)
	end		
	
	def patch()
		if props and props.is_a? Hash then
			@props = props
		end
		
		obj = ET_Patch.new(@authStub, @obj, @props)
	end

	def delete()
		if props and props.is_a? Hash then
			@props = props
		end
		
		obj = ET_Delete.new(@authStub, @obj, @props)
	end	
end

class ET_GetSupportRest < ET_BaseObject
	attr_reader :urlProps, :urlPropsRequired, :lastPageNumber
	
	def initialize
		super
	end
	
	def get(props = nil)		
		if props and props.is_a? Hash then
			@props = props
		end
			
		completeURL = @endpoint		
		additionalQS = {}
		
		if @props and @props.is_a? Hash then		
			@props.each do |k,v|
				if @urlProps.include?(k) then
					completeURL.sub!("{#{k}}", v)
				else 
					additionalQS[k] = v
				end 
			end							
		end		
		
		@urlPropsRequired.each do |value| 
			if !@props || !@props.has_key?(value) then
				raise "Unable to process request due to missing required prop: #{value}"
			end 
		end 
		
		@urlProps.each do |value| 			
			completeURL.sub!("/{#{value}}", "")
		end 		

		obj = ET_GetRest.new(@authStub, completeURL,additionalQS)	
		
		if obj.results.has_key?('page') then 
			@lastPageNumber = obj.results['page']
			pageSize = obj.results['pageSize']
			if obj.results.has_key?('count') then 
				count = obj.results['count']
			elsif obj.results.has_key?('totalCount') then 
				count = obj.results['totalCount']
			end 
					
			if !count.nil? && count > (@lastPageNumber * pageSize)  then 
				obj.moreResults = true	
			end 								
		end 			
		return obj
	end	
	
	def getMoreResults()
		if props and props.is_a? Hash then
			@props = props
		end
		
		originalPageValue = "1"
		removePageFromProps = false			
		
		if !@props.nil? && @props.has_key?('$page') then 
			originalPageValue = @props['page']
		else
			removePageFromProps = true			
		end 
		
		if @props.nil?
			@props = {}
		end 
		
		@props['$page'] = @lastPageNumber + 1
		
		obj = self.get
		
		if removePageFromProps then
			@props.delete('$page')
		else 
			@props['$page'] = originalPageValue
		end		
		
		return obj
	end			
end

class ET_CUDSupportRest < ET_GetSupportRest
	def initialize
		super
	end
	
	def post()		
		completeURL = @endpoint	
		
		if @props and @props.is_a? Hash then		
			@props.each do |k,v|
				if @urlProps.include?(k) then
					completeURL.sub!("{#{k}}", v)
				end 
			end							
		end	
		
		@urlPropsRequired.each do |value| 
			if !@props || !@props.has_key?(value) then
				raise "Unable to process request due to missing required prop: #{value}"
			end 
		end 	
		
		# Clean Optional Parameters from Endpoint URL first 
		@urlProps.each do |value| 			
			completeURL.sub!("/{#{value}}", "")
		end 		

		obj = ET_PostRest.new(@authStub, completeURL, @props)		
	end		
	
	def patch()		
		completeURL = @endpoint		
		# All URL Props are required when doing Patch	
		@urlProps.each do |value| 
			if !@props || !@props.has_key?(value) then
				raise "Unable to process request due to missing required prop: #{value}"
			end 
		end 
		
		if @props and @props.is_a? Hash then		
			@props.each do |k,v|
				if @urlProps.include?(k) then
					completeURL.sub!("{#{k}}", v)
				end 
			end							
		end											
		
		obj = ET_PatchRest.new(@authStub, completeURL, @props)		
	end	
	
	def delete()		
		completeURL = @endpoint		
		# All URL Props are required when doing Patch	
		@urlProps.each do |value| 
			if !@props || !@props.has_key?(value) then
				raise "Unable to process request due to missing required prop: #{value}"
			end 
		end 
		
		if @props and @props.is_a? Hash then		
			@props.each do |k,v|
				if @urlProps.include?(k) then
					completeURL.sub!("{#{k}}", v)
				end 
			end							
		end											
		
		obj = ET_DeleteRest.new(@authStub, completeURL)		
	end	

end 


class ET_GetRest < ET_Constructor
	def initialize(authStub, endpoint, qs = nil)
		authStub.refreshToken	
		
		if qs then 
			qs['access_token'] = authStub.authToken
		else 
			qs = {"access_token" => authStub.authToken}
		end 		
		
		uri = URI.parse(endpoint)
		uri.query = URI.encode_www_form(qs)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Get.new(uri.request_uri)		
		requestResponse = http.request(request)
		
		@moreResults = false
					
		obj = super(requestResponse, true)						
		return obj
	end
end


class ET_ContinueRest < ET_Constructor
	def initialize(authStub, endpoint, qs = nil)
		authStub.refreshToken	
		
		if qs then 
			qs['access_token'] = authStub.authToken
		else 
			qs = {"access_token" => authStub.authToken}
		end 		
		
		uri = URI.parse(endpoint)
		uri.query = URI.encode_www_form(qs)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Get.new(uri.request_uri)		
		requestResponse = http.request(request)
		
		@moreResults = false
					
		super(requestResponse, true)			
	end
end


class ET_PostRest < ET_Constructor
	def initialize(authStub, endpoint, payload)
		authStub.refreshToken
		
		qs = {"access_token" => authStub.authToken}			
		uri = URI.parse(endpoint)
		uri.query = URI.encode_www_form(qs)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = 	payload.to_json
		request.add_field "Content-Type", "application/json"		
		requestResponse = http.request(request)		
					
		super(requestResponse, true)			
	
	end
end

class ET_PatchRest < ET_Constructor
	def initialize(authStub, endpoint, payload)
		authStub.refreshToken
		
		qs = {"access_token" => authStub.authToken}
		uri = URI.parse(endpoint)
		uri.query = URI.encode_www_form(qs)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Patch.new(uri.request_uri)
		request.body = 	payload.to_json
		request.add_field "Content-Type", "application/json"		
		requestResponse = http.request(request)
		super(requestResponse, true)			
	
	end
end

class ET_DeleteRest < ET_Constructor
	def initialize(authStub, endpoint)
		authStub.refreshToken
		
		qs = {"access_token" => authStub.authToken}
			
		uri = URI.parse(endpoint)
		uri.query = URI.encode_www_form(qs)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Delete.new(uri.request_uri)		
		requestResponse = http.request(request)
		super(requestResponse, true)			
	
	end
end

class ET_Campaign < ET_CUDSupportRest
	def initialize
		super
		@endpoint = 'https://www.exacttargetapis.com/hub/v1/campaigns/{id}'
		@urlProps = ["id"]
		@urlPropsRequired = []		
	end	
	
	class Asset < ET_CUDSupportRest
		def initialize
			super
			@endpoint = 'https://www.exacttargetapis.com/hub/v1/campaigns/{id}/assets/{assetId}'
			@urlProps = ["id", "assetId"]
			@urlPropsRequired = ["id"]		
		end	
	end
end

class ET_Subscriber < ET_CUDSupport	
	def initialize
		super
		@obj = 'Subscriber'
	end	
end

class ET_DataExtension < ET_CUDSupport
	attr_accessor :columns
	
	def initialize
		super
		@obj = 'DataExtension'
	end	
	
	def post 
		originalProps = @props

		if @props.is_a? Array then
			multiDE = []
			@props.each { |currentDE|
				
				currentDE['columns'].each { |key|
					currentDE['Fields'] = {}
					currentDE['Fields']['Field'] = []				
					currentDE['Fields']['Field'].push(key)					
				}
				currentDE.delete('columns')				
				multiDE.push(currentDE.dup)
			}
		
			@props = multiDE
		else
			@props['Fields'] = {}
			@props['Fields']['Field'] = []
			
			@columns.each { |key|		
			@props['Fields']['Field'].push(key)
			}
		end		
		
		obj = super		
		@props = originalProps	
		return obj			
	end 

	def patch 
		@props['Fields'] = {}
		@props['Fields']['Field'] = []
		@columns.each { |key|
			@props['Fields']['Field'].push(key)
		}
		obj = super		
		@props.delete("Fields") 		
		return obj			
	end 	
	
	class Column < ET_GetSupport	
		def initialize
			super
			@obj = 'DataExtensionField'
		end	
		
		def get
		
			if props and props.is_a? Array then
				@props = props
			end
			
			if @props and @props.is_a? Hash then
				@props = @props.keys
			end

			if filter and filter.is_a? Hash then
				@filter = filter
			end
			
			fixCustomerKey = false 
			if filter and filter.is_a? Hash then
				@filter = filter
				if @filter.has_key?("Property") && @filter["Property"] == "CustomerKey" then
					@filter["Property"]  = "DataExtension.CustomerKey"
					fixCustomerKey = true 
				end 
			end
			
			obj = ET_Get.new(@authStub, @obj, @props, @filter)						
			@lastRequestID = obj.request_id	
			
			if fixCustomerKey then
				@filter["Property"] = "CustomerKey"
			end 
			
			return obj			
		end 
	end
	
	class Row < ET_CUDSupport
		attr_accessor :Name, :CustomerKey		
				
		def initialize()								
			super
			@obj = "DataExtensionObject"
		end	
		
		def get
			getName
			if props and props.is_a? Array then
				@props = props
			end
			
			if @props and @props.is_a? Hash then
				@props = @props.keys
			end

			if filter and filter.is_a? Hash then
				@filter = filter
			end
			
			obj = ET_Get.new(@authStub, "DataExtensionObject[#{@Name}]", @props, @filter)						
			@lastRequestID = obj.request_id				
			
			return obj
		end
		
		def post			
			getCustomerKey
			originalProps = @props
			## FIX THIS 
			if @props.is_a? Array then
=begin				
				multiRow = []
				@props.each { |currentDE|
					
					currentDE['columns'].each { |key|
						currentDE['Fields'] = {}
						currentDE['Fields']['Field'] = []				
						currentDE['Fields']['Field'].push(key)					
					}
					currentDE.delete('columns')				
					multiRow.push(currentDE.dup)
				}
				
				@props = multiRow
=end				
			else
				currentFields = []
				currentProp = {}
				
				@props.each { |key,value|
					currentFields.push({"Name" => key, "Value" => value})
				}
				currentProp['CustomerKey'] = @CustomerKey
				currentProp['Properties'] = {}
				currentProp['Properties']['Property'] = currentFields	
			end		
			
			obj = ET_Post.new(@authStub, @obj, currentProp)	
			@props = originalProps
			return obj			
		end 
		
		def patch 
			getCustomerKey								
			currentFields = []
			currentProp = {}
			
			@props.each { |key,value|
				currentFields.push({"Name" => key, "Value" => value})
			}
			currentProp['CustomerKey'] = @CustomerKey
			currentProp['Properties'] = {}
			currentProp['Properties']['Property'] = currentFields									
			
			obj = ET_Patch.new(@authStub, @obj, currentProp)	
		end 
		def delete 
			getCustomerKey								
			currentFields = []
			currentProp = {}
			
			@props.each { |key,value|
				currentFields.push({"Name" => key, "Value" => value})
			}
			currentProp['CustomerKey'] = @CustomerKey
			currentProp['Keys'] = {}
			currentProp['Keys']['Key'] = currentFields									
			
			obj = ET_Delete.new(@authStub, @obj, currentProp)	
		end 		
		
		private
		def getCustomerKey			
			if @CustomerKey.nil? then
				if @CustomerKey.nil? && @Name.nil? then 	
					raise 'Unable to process DataExtension::Row request due to CustomerKey and Name not being defined on ET_DatExtension::row'	
				else 	
					de = ET_DataExtension.new
					de.authStub = @authStub
					de.props = ["Name","CustomerKey"]
					de.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => @Name}
					getResponse = de.get
					if getResponse.status && (getResponse.results.length == 1) then 
						@CustomerKey = getResponse.results[0][:customer_key]
					else 
						raise 'Unable to process DataExtension::Row request due to unable to find DataExtension based on Name'
					end 	
				end
			end 
		end
				
		def getName
			if @Name.nil? then
				if @CustomerKey.nil? && @Name.nil? then 	
					raise 'Unable to process DataExtension::Row request due to CustomerKey and Name not being defined on ET_DatExtension::row'	
				else 
					de = ET_DataExtension.new
					de.authStub = @authStub
					de.props = ["Name","CustomerKey"]
					de.filter = {'Property' => 'CustomerKey','SimpleOperator' => 'equals','Value' => @CustomerKey}
					getResponse = de.get
					if getResponse.status && (getResponse.results.length == 1) then 
						@Name = getResponse.results[0][:name]
					else 
						raise 'Unable to process DataExtension::Row request due to unable to find DataExtension based on CustomerKey'
					end 	
				end
			end 
		end								
	end
end

class ET_List < ET_CUDSupport
	def initialize
		super
		@obj = 'List'
	end	
	
	class Subscriber < ET_GetSupport
		def initialize
			super
			@obj = 'ListSubscriber'
		end		
	end
end

class ET_Email < ET_CUDSupport
	def initialize
		super
		@obj = 'Email'
	end	
end

class ET_TriggeredSend < ET_CUDSupport	
	attr_accessor :subscribers
	def initialize
		super
		@obj = 'TriggeredSendDefinition'
	end	
	
	def send 	
		@tscall = {"TriggeredSendDefinition" => @props, "Subscribers" => @subscribers}
		obj = ET_Post.new(@authStub, "TriggeredSend", @tscall)
	end
end

class ET_ContentArea < ET_CUDSupport	
	def initialize
		super
		@obj = 'ContentArea'
	end	
end

class ET_SentEvent < ET_GetSupport
	def initialize
		super
		@obj = 'SentEvent'
	end	
end

class ET_OpenEvent < ET_GetSupport
	def initialize
		super
		@obj = 'OpenEvent'
	end	
end

class ET_BounceEvent < ET_GetSupport
	def initialize
		super
		@obj = 'BounceEvent'
	end	
end

class ET_UnsubEvent < ET_GetSupport
	def initialize
		super
		@obj = 'UnsubEvent'
	end	
end

class ET_ClickEvent < ET_GetSupport
	def initialize
		super
		@obj = 'ClickEvent'
	end	
end
