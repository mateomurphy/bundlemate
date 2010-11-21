require 'spec'
require File.join(File.dirname(__FILE__), *%w[../lib/bundle_mate])

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
