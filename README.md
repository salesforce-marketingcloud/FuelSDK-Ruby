FuelSDK-Ruby
============

ExactTarget Fuel SDK for Ruby

## Overview ##
The Fuel SDK for Ruby provides easy access to ExactTarget's Fuel API Family services, including a collection of REST APIs and a SOAP API. These APIs provide access to ExactTarget functionality via common collection types such as array/hash.

## Requirements ##
Ruby Version 1.9.3

## Getting Started ##
Add this line to your application's Gemfile:

```ruby
gem 'fuelsdk'
```

If you have not registered your application or you need to lookup your Application Key or Application Signature values, please go to App Center at [Code@: ExactTarget's Developer Community](http://code.exacttarget.com/appcenter "Code@ App Center").

## Example Request ##
All ExactTarget objects exposed through the Fuel SDK begin with be prefixed with "ET\_".  Start by working with the ET_List object:

Add a require statement to reference the Fuel SDK's functionality:
> require 'fuelsdk'

Next, create an instance of the ET_Client class:
> myClient = FuelSDK::ET_Client.new {'client' => { 'id' => CLIENTID, 'secret' => SECRET }}

Create an instance of the object type we want to work with:
> list = FuelSDK::ET_List.new

Associate the ET_Client to the object using the authStub property:
> list.authStub = myClient

Utilize one of the ET_List methods:
> response = list.get

Print out the results for viewing
> p response

**Example Output:**

<pre>
<FuelSDK::SoapResponse:0x007fb86abcf190
 @body= {:retrieve_response_msg=> {:overall_status=>"OK", :request_id=>"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", :results=> ...
 @code= 200,
 @message= 'OK',
 @request_id="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
 @results=
  [{:client=>{:id=>"xxxx"},
    :partner_key=>nil,
    :created_date=>
     #<DateTime: 2013-05-30T23:02:00+00:00 ((2456443j,82920s,0n),+0s,2299161j)>,
    :id=>"xxxx",
    :object_id=>nil,
    :email_address=>"xxxx",
    :attributes=>
     [{:name=>"Full Name", :value=>"Justin Barber"},
      {:name=>"Gender", :value=>nil},
      {:name=>"Email Address", :value=>"xxx"},
      {:name=>"User Defined", :value=>"02/02/1982"}],
    :subscriber_key=>"xxxx",
    :status=>"Active",
    :email_type_preference=>"HTML",
    :"@xsi:type"=>"Subscriber"},
 @success=true>
</pre>

## ET\_Client Class ##

The ET\_Client class takes care of many of the required steps when accessing ExactTarget's API, including retrieving appropriate access tokens, handling token state for managing refresh, and determining the appropriate endpoints for API requests.  In order to leverage the advantages this class provides, use a single instance of this class for an entire session.  Do not instantiate a new ET_Client object for each request made.

## Responses ##
All methods on Fuel SDK objects return a generic object that follows the same structure, regardless of the type of call.  This object contains a common set of properties used to display details about the request.

- success?: Boolean value that indicates if the call was successful
- code: HTTP Error Code (will always be 200 for SOAP requests)
- message: Text values containing more details in the event of an error
- results: Collection containing the details unique to the method called.

Get Methods also return an addition value to indicate if more information is available (that information can be retrieved using the getMoreResults method):

 - more? - Boolean value that indicates on Get requests if more data is available.


## Samples ##
Find more sample files that illustrate using all of the available functions for ExactTarget objects exposed through the API in the samples directory.

Sample List:

 - [BounceEvent](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-bounceevent.rb)
 - [Campaign](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-campaign.rb)
 - [ClickEvent](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-clickevent.rb)
 - [ContentArea](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-contentarea.rb)
 - [DataExtension](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-dataextension.rb)
 - [Email](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-email.rb)
 - [List](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-list.rb)
 - [List > Subscriber](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-list.subscriber.rb)
 - [OpenEvent](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-openevent.rb)
 - [SentEvent](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-sentevent.rb)
 - [Subscriber](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-subscriber.rb)
 - [TriggeredSend](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-triggeredsend.rb)
 - [UnsubEvent](https://github.com/ExactTarget/FuelSDK-Ruby/blob/master/samples/sample-unsubevent.rb)






