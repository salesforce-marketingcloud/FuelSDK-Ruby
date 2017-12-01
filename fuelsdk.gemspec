# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fuelsdk/version'

Gem::Specification.new do |spec|
  spec.name          = "fuelsdk-sc"
  spec.version       = FuelSDK::VERSION
  spec.authors       = ["MichaelAllenClark", "barberj"]
  spec.email         = []
  spec.description   = %q{Fuel SDK for Ruby}
  spec.summary       = %q{Fuel SDK for Ruby}
  spec.homepage      = "https://github.com/ExactTarget/FuelSDK-Ruby"
  spec.license       = ""

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(samples|test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"

  spec.add_dependency "savon", "2.2.0"
  spec.add_dependency "json", "~> 1.8.1"
  spec.add_dependency "jwt", "< 2"
end
