require 'rubygems'
require 'open-uri'
require 'savon'
require 'date'
#include ActiveModel::MassAssignmentSecurity

#to-do:
#work on digest authentication - not supported will use OAuth when it's officially GA
#add support for stack detection
#support for downloading of and creation of a local WSDL when the local copy is over X days old

#done:
#break SOAP reponse object creation into it's own class

class Constructor
	attr_accessor :status, :code, :message, :properties
		
	def initialize(response)	
		envelope = response.hash[:envelope]
		@@body = envelope[:body]
			
		if ((!response.soap_fault.present?) or (!response.http_error.present?)) then
			@code = response.http.code
			@status = true
		elsif (response.soap_fault.present?) then
			@code = response.http.code
			@message = response.soap_fault.to_s
			@status = false
		elsif (response.http_error.present?) then
			@code = response.http.code
			@message = response.http_error.to_s
			@status = false         
		end
	end
end

class CreateWSDL
  
  def initialize
    
    #Get the header info for the correct wsdl
	response = HTTPI.head(@wsdl)
	
	if response and (response.code >= 200 and response.code <= 400) then
		header = response.headers
		#see when the WSDL was last modified
		modifiedTime = Date.parse(header['last-modified'])
    
		#is a local WSDL there
		if (File.file?('ExactTargetWSDL.xml') and File.readable?('ExactTargetWSDL.xml') and !File.zero?('ExactTargetWSDL.xml')) then
			createdTime = File.new('ExactTargetWSDL.xml').mtime.to_date

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
		  #detect date diff between file creation and execution request
		  res = open(@wsdl).read
		  File.open('ExactTargetWSDL.xml','w+') { |f|
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
	attr_accessor :auth, :ready, :status

	def initialize(loc = nil, getWSDL = nil, usn, pwd)

		#stack and endpoints
		stack = {
		  'indy' => {
			:wsdl => 'https://webservice.exacttarget.com/ETFramework.wsdl',
			:endpoint => 'https://webservice.exacttarget.com/Service.asmx'
		  },
		  'vegas' => {
			:wsdl => 'https://webservice.s4.exacttarget.com/ETFramework.wsdl',
			:endpoint => 'https://webservice.s4.exacttarget.com/Service.asmx'
		  }
		}

		#set default endpoint if none was passed
		@endpoint = (loc ? stack[loc][:endpoint] : stack['indy'][:endpoint])
		@wsdl = (loc ? stack[loc][:wsdl] : stack['indy'][:wsdl])
		
		begin
			@auth = Savon::Client.new do |wsdl, http, wsse|
				
				#make a new WSDL
				if getWSDL then
					super()
				end
				
				wsdl.document = File.read('ExactTargetWSDL.xml')
				wsdl.endpoint = @endpoint
				wsse.credentials(usn, pwd)
			end
			# Prevents Savon from Raising an exception when a SOAP Fault occurs
			@auth.config.raise_errors = false
		rescue 
		
		end
		
		if ((@auth.wsdl.soap_actions.length > 0) and (@status >= 200 and @status <= 400)) then
			@ready = true
		else
			@ready = false
		end

	end
end

class ET_Describe < Constructor
	#to-do:
	#add error handling
	#trap for soap faults and http errors
	#pass the code and status back in object
	#pass back only soap body

	attr_accessor :results

	def initialize(authStub = nil, objType = nil)
		begin
			response =  authStub.auth.request :n2, "Describe"  do |soap, wsdl|
				soap.input = [
					("n2:" + "DefinitionRequestMsg")
				]
				soap.body = {
					'DescribeRequests' => {
						'ObjectDefinitionRequest' => {
							'ObjectType' => objType
						}
					}
				}
			end
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
	attr_accessor :results

	def initialize(authStub, objType, props = nil)
	begin
		if props.is_a? Array then 
			obj = {
				'Objects' => [],
				:attributes! => { 'Objects' => { 'xsi:type' => ('wsdl:' + objType) } }
			}
			props.each{ |p|
				obj['Objects'] << p 
			 }
		else
			obj = {
				'Objects' => props,
				:attributes! => { 'Objects' => { 'xsi:type' => ('wsdl:' + objType) } }
			}
		end
		
		
		response =  authStub.auth.request 'Create' 	do |soap, wsdl|
			soap.input = [
			 ( 'wsdl:' + 'CreateRequest')
			]
			
			soap.body = obj
			end
			
	ensure 

		super(response)				
			if @status then
				if @@body[:create_response][:results][:status_code] != "OK"				
					@status = false
				end 
				@message = @@body[:create_response][:results][:status_code] + ' - ' + @@body[:create_response][:results][:status_message]
				@results = @@body[:create_response][:results][:new_id]
			end

		end
	end
end

class ET_Delete < Constructor
	attr_accessor :results

	def initialize(authStub, objType, props = nil)
	begin
		obj = {
			'Objects' => props,
			:attributes! => { 'Objects' => { 'xsi:type' => ('wsdl:' + objType) } }
		}
		
		response =  authStub.auth.request 'Delete' 	do |soap, wsdl|
			soap.input = [
			 ( 'wsdl:' + 'DeleteRequest')
			]
			
			soap.body = obj
			end
	ensure 
		super(response)				
			if @status then
				if @@body[:delete_response][:results][:status_code] != "OK"				
				@status = false
				end 
				@message = @@body[:delete_response][:results][:status_code] + ' - ' + @@body[:delete_response][:results][:status_message]
			end
		end
	end
end

class ET_Put < Constructor
	attr_accessor :results

	def initialize(authStub, objType, props = nil)
	begin
		obj = {
			'Objects' => props,
			:attributes! => { 'Objects' => { 'xsi:type' => ('wsdl:' + objType) } }
		}
		
		response =  authStub.auth.request 'Update' 	do |soap, wsdl|
			soap.input = [
			 ( 'wsdl:' + 'UpdateRequest')
			]
			
			soap.body = obj
			end
	ensure 
		super(response)				
			if @status then
				if @@body[:update_response][:results][:status_code] != "OK"				
					@status = false
				end 				
				@message = @@body[:update_response][:results][:status_code] + ' - ' + @@body[:update_response][:results][:status_message]				
			end
		end
	end
end




class ET_Get < Constructor
	attr_accessor :results

	def initialize(authStub, objType, props = nil, filter = nil)
		if !props then
			resp = Describe.new(authStub, objType)

			if resp then
				props = []
				resp.results.map { |p|
					if p[:is_retrievable] then
						props << p[:name]
					end
				}
			end
		end

		obj = {
			'ObjectType' => objType,
			'Properties' => props
		}

		if filter then
			obj['Filter'] = filter
			obj[:attributes!] = { 'Filter' => { 'xsi:type' => 'wsdl:SimpleFilterPart' } }
		end
		p obj.inspect
		response =  authStub.auth.request "Retrieve"  do |soap, wsdl|
			soap.input = [
				('wsdl:' + 'RetrieveRequestMsg')
			]
			soap.body = {
				'RetrieveRequest' => obj
			}
		end	

		super(response)

		if @status then
			if @@body[:retrieve_response_msg][:overall_status] != "OK" then
				@message = @@body[:retrieve_response_msg][:overall_status]
				@status = false					
			else 
				@results = @@body[:retrieve_response_msg][:results]
			end 
		end
	end
end

class ET_BaseObject
	attr_accessor :authStub, :props, :filter, :extProps
	attr_reader :obj
	
	def initialize
		@authStub = nil
		@props = nil
		@filter = nil
		@extend = nil
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


class ET_List < ET_CRUDSupport
	def initialize
		super
		@obj = 'List'
	end	
end

class ET_Email < ET_CRUDSupport	
	def initialize
		super
		@obj = 'Email'
	end	
end

class ET_Subscriber < ET_CRUDSupport	
	def initialize
		super
		@obj = 'Subscriber'
	end	
end

class TriggeredSend
	attr_accessor :authStub, :props, :filter
	attr_reader :obj
	
	def initialize
		@obj = 'TriggeredSendDefinition'
	end

	def get(props = nil, filter = nil)
		if props and props.is_a? Array then
			@props = props
		end

		if filter and filter.is_a? Hash then
			@filter = filter
		end

		obj = Get.new(@authStub, @obj, props, filter)
	end

	def send()
	end
	
	def info()
		obj = Describe.new(@authStub, @obj)
	end
end

