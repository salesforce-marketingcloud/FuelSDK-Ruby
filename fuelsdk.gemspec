# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fuelsdk/version'

Gem::Specification.new do |spec|
	spec.name          = "fuelsdk"
	spec.version       = FuelSDK::VERSION
	spec.authors       = ["MichaelAllenClark", "barberj", "kellyjandrews"]
	spec.email         = ["code@exacttarget.com"]
	spec.description   = %q{API wrapper for SOAP and REST API with Salesforce Marketing Cloud (ExactTarget)}
	spec.summary       = %q{Fuel Client Library for Ruby}
	spec.homepage      = "https://github.com/ExactTarget/FuelSDK-Ruby"
	spec.license       = ""

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(samples|test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler"
	spec.add_development_dependency 'rake'
	spec.add_development_dependency "rspec-core"
	spec.add_development_dependency "rspec-mocks"
	spec.add_development_dependency "rspec-expectations"
	spec.add_development_dependency "rspec-its"
	spec.add_development_dependency "rspec"
	spec.add_development_dependency "guard"
	spec.add_development_dependency "guard-rspec"

	spec.add_dependency "savon"
	spec.add_dependency "json"
	spec.add_dependency "jwt"
end
