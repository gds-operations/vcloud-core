# SimpleCov must run _first_ according to its README
if ENV['COVERAGE']
  require 'simplecov'

  # monkey-patch to prevent SimpleCov from reporting coverage percentage
  class SimpleCov::Formatter::HTMLFormatter
    def output_message(_message)
      nil
    end
  end

  SimpleCov.adapters.define 'gem' do
    add_filter '/spec/'
    add_filter '/vendor/'

    add_group 'Libraries', '/lib/'
  end

  SimpleCov.minimum_coverage(84)
  SimpleCov.start 'gem'
end

require 'bundler/setup'
require 'vcloud/core'
require 'vcloud/tools/tester'
require 'support/stub_fog_interface.rb'
require 'support/integration_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Set FOG_MOCK=true to enable Fog Mock mode.
# NB: Your test data will need to reflect the 'initial data structure' in 
#     https://github.com/fog/fog/blob/master/lib/fog/vcloud_director/compute.rb#L483
# 
# Use FOG_CREDENTIAL=fog_mock in vcloud_tools_tester
# 
if ENV['FOG_MOCK']
  Fog.mock!
end
