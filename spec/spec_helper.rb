lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'marketingcloudsdk'

RSpec.configure do |config|
  config.mock_with :rspec

  # Use color in STDOUT
  config.color = true

  # Use the specified formatter
  config.formatter = :documentation
end
