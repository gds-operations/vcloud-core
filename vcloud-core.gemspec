# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'vcloud/core/version'

Gem::Specification.new do |s|
  s.name        = 'vcloud-core'
  s.version     = Vcloud::Core::VERSION
  s.authors     = ['Anna Shipman']
  s.email       = ['anna.shipman@digital.cabinet-office.gov.uk']
  s.summary     = 'Core tools for interacting with VMware vCloud Director'
  s.description = 'Core tools for interacting with VMware vCloud Director. Includes VCloud Query, a light wrapper round the vCloud Query API.'
  s.homepage    = 'http://github.com/alphagov/vcloud-core'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) {|f| File.basename(f)}
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.2'

  s.add_runtime_dependency 'fog', '>= 1.22.0'
  s.add_runtime_dependency 'methadone'
  s.add_runtime_dependency 'mustache'
  s.add_development_dependency 'aruba', '~> 0.5.3'
  s.add_development_dependency 'cucumber', '~> 1.3.10'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'simplecov', '~> 0.8.2'
  s.add_development_dependency 'gem_publisher', '1.2.0'
end
