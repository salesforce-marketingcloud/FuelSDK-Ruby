Gem::Specification.new do |s|
  s.name = "fuelsdk"
  s.version = "0.9"
  s.date = "2013-05-10"
  s.summary = "ExactTarget Fuel SDK for Ruby"
  s.email = "gary@500friends.com"
  s.homepage = "http://github.com/gkmlo/FuelSDK-Ruby"
  s.description = "The Fuel SDK for Ruby provides easy access to ExactTarget's Fuel API Family services, including a collection of REST APIs and a SOAP API. These APIs provide access to ExactTarget functionality via common collection types such as array/hash."
  s.has_rdoc = false
  s.authors = ["Michael Allen Clark", "Gary Lo"]
  s.files = ["README.md", "lib/ET_Client.rb"]
  s.add_dependency("savon", "~> 2.0")
  s.add_dependency('json', '~> 1.7.0')
  s.add_dependency('jwt', '= 0.1.6')
end