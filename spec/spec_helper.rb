# SimpleCov must run _first_ according to its README
if ENV['COVERAGE']
  require 'simplecov'

  # monkey-patch to prevent SimpleCov from reporting coverage percentage
  class SimpleCov::Formatter::HTMLFormatter
    def output_message(_message)
      nil
    end
  end

  if SimpleCov.profiles[:gem].nil?
    SimpleCov.profiles.define 'gem' do
      add_filter '/spec/'
      add_filter '/vendor/'

      add_group 'Libraries', '/lib/'
    end
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

# To enable Fog Mock mode use FOG_CREDENTIAL=fog_mock and FOG_MOCK=true
# If you do not have configuration for fog_mock in your vcloud_tools_testing_config.yaml,
# the test data is defined here: https://github.com/fog/fog/blob/master/lib/fog/vcloud_director/compute.rb#L483-L733
# 
if ENV['FOG_MOCK']
  Fog.mock!
end
