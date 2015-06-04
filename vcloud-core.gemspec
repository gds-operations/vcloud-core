# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'vcloud/core/version'

Gem::Specification.new do |s|
  s.name        = 'vcloud-core'
  s.version     = Vcloud::Core::VERSION
  s.authors     = ['GOV.UK Infrastructure']
  s.email       = ['vcloud-tools@digital.cabinet-office.gov.uk']
  s.summary     = 'Core tools for interacting with VMware vCloud Director'
  s.description = 'Core tools for interacting with VMware vCloud Director. Includes vCloud Query, a light wrapper round the vCloud Query API.'
  s.homepage    = 'http://github.com/gds-operations/vcloud-core'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) {|f| File.basename(f)}
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_runtime_dependency 'fog', '~> 1.27'
  # FIXME: Remove fog-core line below once fog/fog-core@58556e4b1 is pulled in by `fog` gem
  s.add_runtime_dependency 'fog-core', '~> 1.0', '>= 1.27.4'
  s.add_runtime_dependency 'mustache', '~> 0.99.0'
  s.add_runtime_dependency 'highline'
  s.add_development_dependency 'gem_publisher', '1.2.0'
  s.add_development_dependency 'mac_address'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'rubocop', '~> 0.23.0'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'vcloud-tools-tester', '~> 1.0'
end
