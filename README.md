FuelSDK-Ruby / MarketingCloudSDK-Ruby
=====================================

ExactTarget Fuel SDK / SalesforceMarektingCloudSDK for Ruby

## Overview ##
The Fuel SDK for Ruby provides easy access to ExactTarget's Fuel API Family services, including a collection of REST APIs and a SOAP API. These APIs provide access to ExactTarget functionality via common collection types such as array/hash.

## New Features in Version 1.3.1 ##
- **Updated below packages to latest version**
  - savon: ">= 2.12.1"
  - json: ">= 2.2.0"
  - jwt: ">= 2.1.0"

## New Features in Version 1.3.0 ##
- **Added Refresh Token support for OAuth2 authentication**
- **Added Web/Public App support for OAuth2 authentication**

    More details on Access Tokens for Web/Public Apps can be found [here](https://developer.salesforce.com/docs/atlas.en-us.mc-app-development.meta/mc-app-development/access-token-app.htm)

    Example of instantiating the Client class:
        
    ```
    myclient = MarketingCloudSDK::Client.new({
        'client' => {
            'id' => '<CLIENT_ID>',
            'secret' => '<CLIENT_SECRET>',
            'request_token_url' => '<AUTH TENANT SPECIFIC ENDPOINT>',
            'soap_endpoint' => '<SOAP TENANT SPECIFIC ENDPOINT>',
            'base_api_url' => '<REST TENANT SPECIFIC ENDPOINT>',
            'use_oAuth2_authentication' => true,
            'account_id' => <TARGET_ACCOUNT_ID>,
            'scope' => '<PERMISSION_LIST>',
            'application_type' => '<APPLICATION_TYPE>',
            'redirect_URI' => '<REDIRECT_URI_FOR_PUBLIC/WEB_APP>',
            'authorization_code' => '<AUTHORIZATION_CODE_FOR_PUBLIC/WEB_APP>'
            }
        })
    ```

 * application_type can have one of the following values: `server`, `public`, `web`. The default value of application_type is `server`.


## New Features in Version 1.2.0 ##
- **OAuth2 authentication support** - [More Details](https://developer.salesforce.com/docs/atlas.en-us.mc-app-development.meta/mc-app-development/integration-considerations.htm)

    To enable OAuth2 authentication, pass ```use_oAuth2_authentication => true``` in the params argument to the Client's class constructor.
    
    Example of instantiating the Client class:
    
    ```
    myclient = MarketingCloudSDK::Client.new({
        'client' => {
            'id' => '<CLIENT_ID>',
            'secret' => '<CLIENT_SECRET>',
            'request_token_url' => '<AUTH TENANT SPECIFIC ENDPOINT>',
            'soap_endpoint' => '<SOAP TENANT SPECIFIC ENDPOINT>',
            'base_api_url' => '<REST TENANT SPECIFIC ENDPOINT>',
            'use_oAuth2_authentication' => true,
            'account_id' => <TARGET_ACCOUNT_ID>,
            'scope' => '<PERMISSION_LIST>'
            }
        })
    ```

## New Features in Version 1.1.0 ##
- **Added support for your tenant's endpoints - [More Details](https://developer.salesforce.com/docs/atlas.en-us.mc-apis.meta/mc-apis/your-subdomain-tenant-specific-endpoints.htm) **
- **MarketingCloudSDK gem will be available as sfmc-fuelsdk-ruby on ruby gems.

## Migrationg to version to version 1.0 ##
- **FuelSDK gem has been renamed to MarketingCloudSDK and will be availbale as marketingcloudsdk on ruby gems.
  
## New Features in Version .9 ##
- **Streamlined Folder Support**: All objects that support folders within the UI now have a standardized property called folderId.
- **Interaction Support**: Now supports Import and Email::SendDefinition objects .
- **Profile Attribute Support**: Added the ability to manage profile attributes through the ProfileAttribute object.
- **Support for single request to Add/Update**:A single request can be made which will create the object if one doesn't already or update one if it does.  This works for Subscriber, DataExtension::Row, and List objects using the Put method.
- **Tracking Events Batching Support**: By default, all tracking event types will only pull new data since the last time a request was made using the same filter.  If you would like to override this functionality to pull all data, simply set the GetSinceLastBatch property to false.
- **Automatic Asset Organization for Hub Apps**: Applications that authenticate by providing a JWT will automatically have all created assets placed into a folder based on the HubExchange app's name. 
- **Greater Flexibility for Authentication**:Yaml config file is no longer required in order to define the authentication parameters.  They are now required inputs when instantiating the Client class so they can be stored anywhere.
 
## Migrating from old version ##
- MarkeitngCloudSDK is now gem, Going forward FuelSDK gem will be available as marketingcloudsdk on ruby gems.
- Config.yaml is no longer used.  ClientID/ClientSecret will now need to be passed when instantiating the Client class.
- Previous versions of the SalesforceMarketingCloudSDK  exposed objects with the prefix "ET_". For backwards compatibility you can still access objects this way.
Subscriber can be accessed using MarketingCloudSDK::Subscriber or ET_Subscriber.  

## Requirements ##
- Ruby Version 2.2.5
- Savon 2.2.0 

## Getting Started ##
Build the gem from the source

```ruby
gem build marketingcloudsdk.gemspec
```

Install the newly built gem

```ruby
gem install marketingcloudsdk-1.3.0.gem
```

If you have not registered your application or you need to lookup your Application Key or Application Signature values, please go to App Center at [Code@: ExactTarget's Developer Community](http://code.exacttarget.com/appcenter "Code@ App Center").


## Example Request ##

Add a require statement to reference the SalesforceMarketingCloud SDK's functionality:
> require 'marketingcloudsdk'

Next, create an instance of the Client class:
> myClient = MarketingCloudSDK::Client.new {'client' => { 'id' => CLIENTID, 'secret' => SECRET }}

Create an instance of the object type we want to work with:
> list = MarketingCloudSDK::List.new

Associate the Client to the object using the client property:
> list.client = myClient

Utilize one of the List methods:
> response = list.get

Print out the results for viewing
> p response

**Example Output:**

<pre>
<MarketingCloudSDK::SoapResponse:0x007fb86abcf190
 @body= {:retrieve_response_msg=> {:overall_status=>"OK", :request_id=>"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", :results=>..}
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

## Client Class ##

The Client class takes care of many of the required steps when accessing ExactTarget's API, including retrieving appropriate access tokens, handling token state for managing refresh, and determining the appropriate endpoints for API requests.  In order to leverage the advantages this class provides, use a single instance of this class for an entire session.  Do not instantiate a new Client object for each request made.

Client class accepts multiple parameters

**Parameters** - Allows for passing authentication information for use with SSO with a JWT or for passing ClientID/ClientSecret. 
Additionally the API hostname (base_api_url),Authentication URL (request_token_url) and the SOAP endpoint (soap_endpoint) is now configurable:

Example passing ClientID/ClientSecret: 
> myclient = MarketingCloudSDK::Client.new({'client' => {'id' => 'exampleID','secret' => 'exampleSecret'}})

Example passing ClientID/ClientSecret/AppSignature/JWT: 
> myclient = MarketingCloudSDK::Client.new({'client' => {'id' => 'exampleID','secret' => 'exampleSecret', 'signature'=>'examplesig'}, 'jwt'=>'exampleJWT'})

Example passing ClientID/ClientSecret/BaseAPIUrl/ReqTokenAuthUrl/Soap Endpoint
> myclient = MarketingCloudSDK::Client.new('client' => {'id' => 'exampleID', 'secret' => 'exampleSecret', 'base_api_url' => 'http://getapis', 'request_token_url' => 'http://authapi', 'soap_endpoint' => 'http://soapendpoint'})

**Note** - The following defaults apply if the following parameters are omitted:
- base_api_url: https://www.exacttargetapis.com
- request_token_url: https://auth.exacttargetapis.com/v1/requestToken
- soap_endpoint: https://webservice.exacttarget.com/Service.asmx

**Debug** - If 2nd parameter for debug is set to true, all API requests that the Fuel SDK is making behind the scenes will be logged.  This option should only be set to true in order to troubleshoot during the development process and should never be used in a production scenario.
> myclient = MarketingCloudSDK::Client.new auth, true <br> 


## Responses ##
All methods on MarketingCloud SDK objects return a generic object that follows the same structure, regardless of the type of call.  This object contains a common set of properties used to display details about the request.

- success?: Boolean value that indicates if the call was successful
- code: HTTP Error Code (will always be 200 for SOAP requests)
- message: Text values containing more details in the event of an error
- results: Collection containing the details unique to the method called.
 - more? - Boolean value that indicates on Get requests if more data is available.


## Samples ##
Find more sample files that illustrate using all of the available functions for ExactTarget objects exposed through the API in the samples directory.






