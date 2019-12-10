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

module MarketingCloudSDK
	module Objects
		module Soap
			module Read
				attr_accessor :filter
				def get _id=nil
					client.soap_get _id||id, properties, filter
				end

				def info
					client.soap_describe id
				end
			end

			module CUD #create, update, delete
				def post
					if self.respond_to?('folder_property') && !self.folder_id.nil?
						properties[self.folder_property]  = self.folder_id
					elsif self.respond_to?('folder_property') && !self.folder_property.nil? && !client.package_name.nil? then
						if client.package_folders.nil? then
							getPackageFolder = ET_Folder.new
							getPackageFolder.authStub = client
							getPackageFolder.properties = ["ID", "ContentType"]
							getPackageFolder.filter = {"Property" => "Name", "SimpleOperator" => "equals", "Value" => client.package_name}
							resultPackageFolder = getPackageFolder.get
							if resultPackageFolder.status then
								client.package_folders = {}
								resultPackageFolder.results.each do |value|
									client.package_folders[value[:content_type]] = value[:id]
								end
							else
								raise "Unable to retrieve folders from account due to: #{resultPackageFolder.message}"
							end
						end

						if !client.package_folders.has_key?(self.folder_media_type) then
							if client.parentFolders.nil? then
								parentFolders = ET_Folder.new
								parentFolders.authStub = client
								parentFolders.properties = ["ID", "ContentType"]
								parentFolders.filter = {"Property" => "ParentFolder.ID", "SimpleOperator" => "equals", "Value" => "0"}
								resultParentFolders = parentFolders.get
								if resultParentFolders.status then
									client.parent_folders = {}
									resultParentFolders.results.each do |value|
										client.parent_folders[value[:content_type]] = value[:id]
									end
								else
									raise "Unable to retrieve folders from account due to: #{resultParentFolders.message}"
								end
							end

							newFolder = ET_Folder.new
							newFolder.authStub = client
							newFolder.properties = {"Name" => client.package_name, "Description" => client.package_name, "ContentType"=> self.folder_media_type, "IsEditable"=>"true", "ParentFolder" => {"ID" => client.parentFolders[self.folder_media_type]}}
							folderResult = newFolder.post
							if folderResult.status then
								client.package_folders[self.folder_media_type]  = folderResult.results[0][:new_id]
							else
								raise "Unable to create folder for Post due to: #{folderResult.message}"
							end

						end
						properties[self.folder_property] = client.package_folders[self.folder_media_type]
					end
					client.soap_post id, properties
				end

				def patch
					client.soap_patch id, properties
				end

				def delete
					client.soap_delete id, properties
				end
			end

			module Upsert
				def put
					client.soap_put id, properties
				end
			end

		end

		module Rest
			module Read
				def get
					client.rest_get id, properties
				end
			end

			module CUD
				def post
					client.rest_post id, properties
				end

				def patch
					client.rest_patch id, properties
				end

				def delete
					client.rest_delete id, properties
				end
			end

		end

		class Base
			attr_accessor :properties, :client
			attr_reader :id

			alias props= properties= # backward compatibility
			alias authStub= client= # backward compatibility

			def properties
				#@properties = [@properties].compact unless @properties.kind_of? Array
				@properties
			end

			#Backwards compatibility
			def props
				@properties
			end

			def id
				self.class.id
			end

			class << self
				def id
					self.name.split('::').pop
				end
			end
		end
	end

	class BounceEvent < Objects::Base
		attr_accessor :get_since_last_batch
		include Objects::Soap::Read
	end

	class ClickEvent < Objects::Base
		attr_accessor :get_since_last_batch
		include Objects::Soap::Read
	end

	class ContentArea < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD
		attr_accessor :folder_id

		def folder_property
			'CategoryID'
		end

		def folder_media_type
			'content'
		end
	end

	class DataFolder < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD
	end

	class Folder < DataFolder
		class << self
			def id
				DataFolder.id
			end
		end
	end

	class Email < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD
		attr_accessor :folder_id

		def folder_property
			'CategoryID'
		end

		def folder_media_type
			'email'
		end

		class SendDefinition < Objects::Base
			include Objects::Soap::Read
			include Objects::Soap::CUD
			attr_accessor :folder_id

			def id
				'EmailSendDefinition'
			end

			def folder_property
				'CategoryID'
			end

			def folder_media_type
				'userinitiatedsends'
			end


			def send
				perform_response = client.soap_perform id, 'start' , properties
				if perform_response.status then
					@last_task_id = perform_response.results[0][:result][:task][:id]
				end
				perform_response
			end

			def status
				client.soap_get "Send", ['ID','CreatedDate', 'ModifiedDate', 'Client.ID', 'Email.ID', 'SendDate','FromAddress','FromName','Duplicates','InvalidAddresses','ExistingUndeliverables','ExistingUnsubscribes','HardBounces','SoftBounces','OtherBounces','ForwardedEmails','UniqueClicks','UniqueOpens','NumberSent','NumberDelivered','NumberTargeted','NumberErrored','NumberExcluded','Unsubscribes','MissingAddresses','Subject','PreviewURL','SentDate','EmailName','Status','IsMultipart','SendLimit','SendWindowOpen','SendWindowClose','BCCEmail','EmailSendDefinition.ObjectID','EmailSendDefinition.CustomerKey'], {'Property' => 'ID','SimpleOperator' => 'equals','Value' => @last_task_id}
			end

			private
			attr_accessor :last_task_id

		end
	end



	class Import < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD


		def id
			'ImportDefinition'
		end

		def post
			originalProp = properties
			cleanProps
			obj = super
			properties = originalProp
			return obj
		end

		def patch
			originalProp = properties
			cleanProps
			obj = super
			properties = originalProp
			return obj
		end

		def start
			perform_response = client.soap_perform id, 'start' , properties
			if perform_response.status then
				@last_task_id = perform_response.results[0][:result][:task][:id]
			end
			perform_response
		end

		def status
			client.soap_get "ImportResultsSummary", ['ImportDefinitionCustomerKey','TaskResultID','ImportStatus','StartDate','EndDate','DestinationID','NumberSuccessful','NumberDuplicated','NumberErrors','TotalRows','ImportType'], {'Property' => 'TaskResultID','SimpleOperator' => 'equals','Value' => @last_task_id}
		end

		private
		attr_accessor :last_task_id

		def cleanProps
			# If the ID property is specified for the destination then it must be a list import
			if properties.has_key?('DestinationObject') then
				if properties['DestinationObject'].has_key?('ID') then
					properties[:attributes!] = { 'DestinationObject' => { 'xsi:type' => 'tns:List'}}
				end
			end
		end
	end


	class List < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD
		attr_accessor :folder_id

		def folder_property
			'Category'
		end

		def folder_media_type
			'list'
		end

		class Subscriber < Objects::Base
			include Objects::Soap::Read
			def id
				'ListSubscriber'
			end
		end
	end

	class OpenEvent < Objects::Base
		attr_accessor :get_since_last_batch
		include Objects::Soap::Read
	end

	class SentEvent < Objects::Base
		attr_accessor :get_since_last_batch
		include Objects::Soap::Read
	end

	class Subscriber < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD
		include Objects::Soap::Upsert
	end

	class UnsubEvent < Objects::Base
		attr_accessor :get_since_last_batch
		include Objects::Soap::Read
	end

	class ProfileAttribute < Objects::Base
		def get
			client.soap_describe "Subscriber"
		end

		def post
			client.soap_configure "PropertyDefinition","create", properties
		end

		def delete
			client.soap_configure "PropertyDefinition","delete", properties
		end

		def patch
			client.soap_configure "PropertyDefinition","update", properties
		end
	end

	class TriggeredSend < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD
		attr_accessor :folder_id, :subscribers, :attributes
		def id
			'TriggeredSendDefinition'
		end

		def folder_property
			'CategoryID'
		end

		def folder_media_type
			'triggered_send'
		end

		def send
			if self.properties.is_a? Array then
				tscall = []
				self.properties.each{ |p|
					tscall.push({"TriggeredSendDefinition" => {"CustomerKey" => p["CustomerKey"]}, "Subscribers" => p["Subscribers"], "Attributes" => p["Attributes"]})
				}
			else
				tscall = {"TriggeredSendDefinition" => self.properties, "Subscribers" => @subscribers, "Attributes" => @attributes }
      end
			client.soap_post 'TriggeredSend', tscall
		end
	end

	class DataExtension < Objects::Base
		include Objects::Soap::Read
		include Objects::Soap::CUD
		attr_accessor :fields, :folder_id

		def folder_property
			'CategoryID'
		end

		def folder_media_type
			'dataextension'
		end

		alias columns= fields= # backward compatibility

		def post
			munge_fields self.properties
			super
		end

		def patch
			munge_fields self.properties
			super
		end

		class Column < Objects::Base
			include Objects::Soap::Read
			def id
				'DataExtensionField'
			end
			def get
				if filter and filter.kind_of? Hash and \
          filter.include? 'Property' and filter['Property'] == 'CustomerKey'
					filter['Property'] = 'DataExtension.CustomerKey'
				end
				super
			end
		end

		class Row < Objects::Base
			include Objects::Soap::Read
			include Objects::Soap::CUD
			include Objects::Soap::Upsert

			attr_accessor :name, :customer_key

			# backward compatibility
			alias Name= name=
			alias CustomerKey= customer_key=

			def id
				'DataExtensionObject'
			end

			def get
				super "#{id}[#{name}]"
			end

			def name
				unless @name
					retrieve_required
				end
				@name
			end

			def customer_key
				unless @customer_key
					retrieve_required
				end
				@customer_key
			end

			def post
				munge_properties self.properties
				super
			end

			def patch
				munge_properties self.properties
				super
			end

			def put
				munge_properties self.properties
				super
			end

			def delete
				munge_keys self.properties
				super
			end

			private
			#::TODO::
			# opportunity for meta programming here... but need to get this out the door
			def munge_keys d
				if d.kind_of? Array
					d.each do |o|

						next if explicit_keys(o) && explicit_customer_key(o)

						formatted = []
						o['CustomerKey'] = customer_key unless explicit_customer_key o
						unless explicit_properties(o)
							o.each do |k, v|
								next if k == 'CustomerKey'
								formatted.concat MarketingCloudSDK.format_name_value_pairs k => v
								o.delete k
							end
							o['Keys'] = {'Key' => formatted }
						end
					end
				else
					formatted = []
					d.each do |k, v|
						next if k == 'CustomerKey'
						formatted.concat MarketingCloudSDK.format_name_value_pairs k => v
						d.delete k
					end
					d['CustomerKey'] = customer_key
					d['Keys'] = {'Key' => formatted }
				end
			end

			def explicit_keys h
				h['Keys'] and h['Keys']['Key']
			end

			def munge_properties d
				if d.kind_of? Array
					d.each do |o|
						next if explicit_properties(o) && explicit_customer_key(o)

						formatted = []
						o['CustomerKey'] = customer_key unless explicit_customer_key o
						unless explicit_properties(o)
							o.each do |k, v|
								next if k == 'CustomerKey'
								formatted.concat MarketingCloudSDK.format_name_value_pairs k => v
								o.delete k
							end
							o['Properties'] = {'Property' => formatted }
						end
					end
				else
					formatted = []
					d.each do |k, v|
						formatted.concat MarketingCloudSDK.format_name_value_pairs k => v
						d.delete k
					end
					d['CustomerKey'] = customer_key
					d['Properties'] = {'Property' => formatted }
				end
			end

			def explicit_properties h
				h['Properties'] and h['Properties']['Property']
			end

			def explicit_customer_key h
				h['CustomerKey']
			end

			def retrieve_required
				# have to use instance variables so we don't recursivelly retrieve_required
				if !@name && !@customer_key
					raise 'Unable to process DataExtension::Row ' \
              'request due to missing CustomerKey and Name'
				end
				if !@name || !@customer_key
					filter = {
						'Property' => @name.nil? ? 'CustomerKey' : 'Name',
						'SimpleOperator' => 'equals',
						'Value' => @customer_key || @name
					}
					rsp = client.soap_get 'DataExtension', ['Name', 'CustomerKey'], filter
					if rsp.success? && rsp.results.count == 1
						self.name = rsp.results.first[:name]
						self.customer_key = rsp.results.first[:customer_key]
					else
						raise 'Unable to process DataExtension::Row'
					end
				end
			end
		end

		private

		def munge_fields d
			# maybe one day will make it smart enough to zip properties and fields if count is same?
			if d.kind_of? Array and d.count > 1 and (fields and !fields.empty?)
				# we could map the field to all DataExtensions, but lets make user be explicit.
				# if they are going to use fields attribute properties should
				# be a single DataExtension Defined in a Hash
				raise 'Unable to handle muliple DataExtension definitions and a field definition'
			end

			if d.kind_of? Array
				d.each do |de|
					if (explicit_fields(de) and (de['columns'] || de['fields'] || has_fields)) or
						(de['columns'] and (de['fields'] || has_fields)) or
						(de['fields'] and has_fields)
						raise 'Fields are defined in too many ways. Please only define once.' # ahhh what, to do...
					end

					# let users who chose, to define fields explicitly within the hash definition
					next if explicit_fields de

					de['Fields'] = {'Field' => de['columns'] || de['fields'] || fields}
					# sanitize

					raise 'DataExtension needs atleast one field.' unless de['Fields']['Field']
				end
			else
				self.properties['Fields'] = {'Field' => self.properties['columns'] || self.properties['fields'] || fields}
				raise 'DataExtension needs atleast one field.' unless self.properties['Fields']['Field']
				self.properties.delete 'columns'
				self.properties.delete 'fields'
			end
		end

		def explicit_fields h
			h['Fields'] and h['Fields']['Field']
		end

		def has_fields
			fields and !fields.empty?
		end
	end

	class Campaign < Objects::Base
		include Objects::Rest::Read
		include Objects::Rest::CUD

		def properties
			@properties ||= {}
			@properties.merge! 'id' => '' unless @properties.include? 'id'
			@properties
		end

		def id
			self.client.base_api_url + '/hub/v1/campaigns/%{id}'
		end

		class Asset < Objects::Base
			include Objects::Rest::Read
			include Objects::Rest::CUD

			def properties
				@properties ||= {}
				@properties.merge! 'assetId' => '' unless @properties.include? 'assetId'
				@properties
			end

			def id
				self.client.base_api_url + '/hub/v1/campaigns/%{id}/assets/%{assetId}'
			end
		end
	end

	# Direct Verb Access Section

	class Get < Objects::Base
		include Objects::Soap::Read
		attr_accessor :id

		def initialize client, id, properties, filter
			self.properties = properties
			self.filter = filter
			self.client = client
			self.id = id
		end

		def get
			super id
		end

		class << self
			def new client, id, properties=nil, filter=nil
				o = self.allocate
				o.send :initialize, client, id, properties, filter
				return o.get
			end
		end
	end

	class Post < Objects::Base
		include Objects::Soap::CUD
		attr_accessor :id

		def initialize client, id, properties
			self.properties = properties
			self.client = client
			self.id = id
		end

		def post
			super
		end

		class << self
			def new client, id, properties=nil
				o = self.allocate
				o.send :initialize, client, id, properties
				return o.post
			end
		end
	end

	class Delete < Objects::Base
		include Objects::Soap::CUD
		attr_accessor :id

		def initialize client, id, properties
			self.properties = properties
			self.client = client
			self.id = id
		end

		def delete
			super
		end

		class << self
			def new client, id, properties=nil
				o = self.allocate
				o.send :initialize, client, id, properties
				return o.delete
			end
		end
	end

	class Patch < Objects::Base
		include Objects::Soap::CUD
		attr_accessor :id

		def initialize client, id, properties
			self.properties = properties
			self.client = client
			self.id = id
		end

		def patch
			super
		end

		class << self
			def new client, id, properties=nil
				o = self.allocate
				o.send :initialize, client, id, properties
				return o.patch
			end
		end
	end

end
