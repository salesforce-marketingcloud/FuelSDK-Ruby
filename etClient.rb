require 'rubygems'
require 'open-uri'
require 'savon'
require 'date'
require 'json'
require 'yaml'
require 'jwt'

#to-do:
#work on digest authentication - not supported will use OAuth when it's officially GA
#add support for stack detection

class Constructor
	attr_accessor :status, :code, :message, :properties, :results, :request_id, :moreData
		
	def initialize(response = nil)
		@results = []
		if !response.nil? then 
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
		end 
	end
end

class CreateWSDL
  
  def initialize(path)
    #Get the header info for the correct wsdl
	response = HTTPI.head(@wsdl)
	if response and (response.code >= 200 and response.code <= 400) then
		header = response.headers
		#see when the WSDL was last modified
		modifiedTime = Date.parse(header['last-modified'])
		p = path + '/ExactTargetWSDL.xml'
		#is a local WSDL there
		if (File.file?(p) and File.readable?(p) and !File.zero?(p)) then
			createdTime = File.new(p).mtime.to_date
			
			#is the locally created WSDL older than the production WSDL
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

class ETClient < CreateWSDL
	attr_accessor :auth, :ready, :status, :debug
	attr_reader :authToken, :authTokenExpiration, :internalAuthToken, :wsdlLoc, :clientId, :clientSecret, :soapHeader, :authObj, :path, :appsignature, :stackID, :refreshKey 

	def initialize(loc = nil, getWSDL = nil, debug = nil, params = nil)	
		config = YAML.load_file("config.yaml")		
		@stackID = loc		
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
			#path of current folder
			@path = File.dirname(__FILE__)
			
			#make a new WSDL
			if getWSDL then
				super(@path)
			end				
			
			if params && params.has_key?("jwt") then
				p 'Lets use the JWT'
				jwt = JWT.decode(params["jwt"], nil, false);
				p jwt
				@authToken = jwt['request']['user']['oauthToken']
				@authTokenExpiration = Time.new + jwt['request']['user']['expiresIn']
				@internalAuthToken = jwt['request']['user']['internalOauthToken']
				@refreshKey = jwt['request']['user']['refreshToken']
				p "authToken: #{@authToken} authTokenExpiration: #{@authTokenExpiration} internalAuthToken: #{@internalAuthToken} refreshKey: #{@refreshKey} "
				
				self.determineStack
				
				@authObj = {'oAuth' => {'oAuthToken' => @internalAuthToken}}			
				@authObj[:attributes!] = { 'oAuth' => { 'xmlns' => 'http://exacttarget.com' }}						
				
				myWSDL = File.read(@path + '/ExactTargetWSDL.xml')
				@auth = Savon.client(soap_header: @authObj, wsdl: myWSDL, endpoint: @endpoint, wsse_auth: ["*", "*"],raise_errors: false, log: @debug) 				
			else 
				p 'NO JWT'
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
		if ((@authToken.nil? || Time.new - 300 > @authTokenExpiration) || force) then 
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
			@authToken = tokenResponse['accessToken']
			@authTokenExpiration = Time.new + tokenResponse['expiresIn']
			@internalAuthToken = tokenResponse['legacyToken']
			if tokenResponse.has_key?("refreshToken") then
				@refreshKey = tokenResponse['refreshToken']
			end
			
			self.determineStack
			
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
	
	def determineStack()		
		begin
			uri = URI.parse("https://www.exacttargetapis.com/platform/v1/endpoints/soap?access_token=" + @authToken)
			http = Net::HTTP.new(uri.host, uri.port)

			http.use_ssl = true
			
			request = Net::HTTP::Get.new(uri.request_uri)		
					
			contextResponse = JSON.parse(http.request(request).body)
			@endpoint = contextResponse['url']
			
			p @endpoint

		rescue Exception => e
			raise 'Unable to determine stack using /platform/v1/tokenContext: ' + e.message  
		end
	end	
end


class ET_Describe < Constructor
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

class ET_Post < Constructor
	def initialize(authStub, objType, props = nil)
	@results = []
		
	begin
		authStub.refreshToken
		obj = {
			'Objects' => props,
			:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }			
		}

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

class ET_Delete < Constructor

	def initialize(authStub, objType, props = nil)
	@results = []
	begin
		authStub.refreshToken
		obj = {
			'Objects' => props,
			:attributes! => { 'Objects' => { 'xsi:type' => ('tns:' + objType) } }
		}
		
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

class ET_Put < Constructor
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

class ET_Continue < Constructor
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
				
			@moreData = false				
			if @@body[:retrieve_response_msg][:overall_status] == "MoreDataAvailable" then
				@moreData = true				 						
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

class ET_Get < Constructor
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
				
			@moreData = false				
			if @@body[:retrieve_response_msg][:overall_status] == "MoreDataAvailable" then
				@moreData = true				 						
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
	attr_accessor :authStub, :props, :filter
	attr_reader :obj, :lastRequestID
	
	def initialize
		@authStub = nil
		@props = nil
		@filter = nil
		@extend = nil
		@moreData = false
	end
end

class ET_CRUDSupport < ET_BaseObject
	
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
	
	def continue()
		obj = ET_Continue.new(@authStub, @lastRequestID)
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
	
	def put()
		if props and props.is_a? Hash then
			@props = props
		end
		
		obj = ET_Put.new(@authStub, @obj, @props)
	end

	def delete()
		if props and props.is_a? Hash then
			@props = props
		end
		
		obj = ET_Delete.new(@authStub, @obj, @props)
	end	
	
	def info()
		obj = ET_Describe.new(@authStub, @obj)
	end	
end



class ET_GetSupport < ET_BaseObject
	
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
	end			
	
	def info()
		obj = ET_Describe.new(@authStub, @obj)
	end	
end


class ET_Subscriber < ET_CRUDSupport	
	def initialize
		super
		@obj = 'Subscriber'
	end	
end

class ET_DataExtension < ET_BaseObject	
	attr_accessor :rows, :columns, :keyCreated
	
	def initialize
		super
		@obj = 'DataExtension'
		@keyCreated = nil
	end	
	
	def get(type, props = nil, filter = nil)
		obj = Constructor.new()
		if filter and filter.is_a? Hash then
			@filter = filter
		end
		
		if type == "Details" then 
			if props and props.is_a? Array then
				@props = props
			end
			
			if @props and @props.is_a? Hash then
				@props = @props.keys
			end

			obj = ET_Get.new(@authStub, @obj, @props, @filter)		
			
		elsif type == "Rows"
			if !@props.nil? &&  (@props.has_key?("Name") || @props.has_key?("CustomerKey")) && @rows then 
				rowObjName = ""
				if @props.has_key?("Name")  then
					rowObjName = "DataExtensionObject[" + @props['Name'] + "]"
					
				# We need to get the Name based on the CustomerKey if CustomerKey was passed in
				elsif @props.has_key?("CustomerKey") 
					obj = ET_Get.new(@authStub, @obj, ["Name"], {"Property" => "CustomerKey", "SimpleOperator" => "equals", "Value" => @props['CustomerKey'] })
					if obj.status and obj.results.length == 1 then 
						rowObjName = "DataExtensionObject[" + obj.results[0][:name] + "]"
					else 
						obj.status = false
						obj.message = "No DataExtension found with the provided CustomerKey"	
						return obj
					end 
				end 
				
				# If they didn't provide an array of field names in the rows, then get the field names from the first row of the rowset
				retrieveRows = @rows
				if (@rows.is_a? Array) && (@rows[0].is_a? Hash) then
					retrieveRows = @rows[0]
				end 
				
				obj = ET_Get.new(@authStub, rowObjName, retrieveRows, @filter)
			elsif !@rows
				obj.status = false
				obj.message = "rows on ET_DataExtension must be defined for Get with Type='Rows' "					
			else 
				obj.status = false
				obj.message = "props on ET_DataExtension must be defined with values for Name or CustomerKey when using Get with Type='Rows'"
			end 
			
		elsif type == "Columns"
			retrieveColumns = @rows
			# If they didn't provide an array of field names in the columns, then get the properties from the first row set
			if (@columns.is_a? Array) && (@columns[0].is_a? Hash) then
				retrieveColumns = @columns[0]
			end 
			
			obj = ET_Get.new(@authStub, "DataExtensionField", retrieveColumns, @filter)
		else 
			obj.status = false
			obj.message = "Invalid type specified for DataExtension Get"
		end 			
		obj
	end	
	
	def continue()
		obj = ET_Continue.new(@authStub, @lastRequestID)
	end			
	
	def post()
		createDE = false
		if @columns && @props['CustomerKey'] != @keyCreated then 
			createDE = true
		end 
			
		if createDE then
			#Create the data extension			
			@props['Fields'] = {}
			@props['Fields']['Field'] = []
			@columns.each { |key|
				@props['Fields']['Field'].push(key)
			}
			obj = ET_Post.new(@authStub, @obj, @props)	
			@keyCreated	 = @props['CustomerKey']
		end	
		
		if @rows then
			@props.delete("Fields")
			rowProps = []
			@rows.each {|value|
				currentProp = {}
				currentFields = []
				value.each { |key,value|
					currentFields.push({"Name" => key, "Value" => value})
				}
				currentProp = @props
				currentProp['Properties'] = {}
				currentProp['Properties']['Property'] = currentFields	
				rowProps.push(currentProp.dup)					
			}		
			
			rowsobj = ET_Post.new(@authStub, "DataExtensionObject", rowProps)
						
			
			#If we created the DE and the Rows merge the results
			if createDE then
				# If either request failed then consider the status to be failed
				if !rowsobj.status || !obj.status then
					obj.status = false
				end 
				obj.results = obj.results + rowsobj.results
			else 
			#Since we only create rows, just use the results from that
				obj = rowsobj
			end 			
		end
		
		obj	
	end		
	
	def put()				
		createDE = false
		if @columns && @props['CustomerKey'] != @keyCreated then 
			createDE = true
		end 
			
		if createDE then
			@props['Fields'] = {}
			@props['Fields']['Field'] = []
			@columns.each { |key|
				@props['Fields']['Field'].push(key)
			}
			obj = ET_Post.new(@authStub, @obj, @props)	
			@keyCreated	 = @props['CustomerKey']
		end	
		
		if @rows then
			@props.delete("Fields")
			rowProps = []
			@rows.each {|value|
				currentProp = {}
				currentFields = []
				value.each { |key,value|
					currentFields.push({"Name" => key, "Value" => value})
				}
				currentProp = @props
				currentProp['Properties'] = {}
				currentProp['Properties']['Property'] = currentFields	
				rowProps.push(currentProp.dup)					
			}		
			
			rowsobj = ET_Put.new(@authStub, "DataExtensionObject", rowProps)
						
			
			#If we created the DE and the Rows merge the results
			if createDE then
				# If either request failed then consider the status to be failed
				if !rowsobj.status || !obj.status then
					obj.status = false
				end 
				obj.results = obj.results + rowsobj.results
			else 
			#Since we only create rows, just use the results from that
				obj = rowsobj
			end 			
		end		
		obj	
	end		

	def delete()
				
		createDE = false
		if @columns && @props['CustomerKey'] != @keyCreated then 
			createDE = true
		end 
			
		if createDE then		
			@props['Fields'] = {}
			@props['Fields']['Field'] = []
			@columns.each { |key|
				@props['Fields']['Field'].push(key)
			}
			obj = ET_Post.new(@authStub, @obj, @props)	
			@keyCreated	 = @props['CustomerKey']
		end	
		
		if @rows then
			@props.delete("Fields")
			rowProps = []
			@rows.each {|value|
				currentProp = {}
				currentFields = []
				value.each { |key,value|
					currentFields.push({"Name" => key, "Value" => value})
				}
				currentProp = @props
				currentProp['Keys'] = {}
				currentProp['Keys']['Key'] = currentFields	
				rowProps.push(currentProp.dup)					
			}		
			
			rowsobj = ET_Delete.new(@authStub, "DataExtensionObject", rowProps)
						
			
			#If we created the DE and the Rows merge the results
			if createDE then
				# If either request failed then consider the status to be failed
				if !rowsobj.status || !obj.status then
					obj.status = false
				end 
				obj.results = obj.results + rowsobj.results
			else 
			#Since we only create rows, just use the results from that
				obj = rowsobj
			end 			
		end
		
		obj	
	end	

end

class ET_List < ET_CRUDSupport
	def initialize
		super
		@obj = 'List'
	end	
end


class ET_TriggeredSend < ET_CRUDSupport	
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
