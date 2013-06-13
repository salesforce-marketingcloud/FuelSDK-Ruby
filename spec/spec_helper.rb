lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fuelsdk'

RSpec.configure do |config|
  config.mock_with :rspec

  # Use color in STDOUT
  config.color_enabled = true

  # Use the specified formatter
  config.formatter = :documentation
end
