# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'vcloud/core/version'

Gem::Specification.new do |s|
  s.name        = 'vcloud-core'
  s.version     = Vcloud::Core::VERSION
  s.authors     = ['Government Digital Service']
  s.summary     = 'Core tools for interacting with VMware vCloud Director'
  s.description = 'Core tools for interacting with VMware vCloud Director'
  s.homepage    = 'http://github.com/alphagov/vcloud-core'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) {|f| File.basename(f)}
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.2'

  s.add_runtime_dependency 'fog', '>= 1.19.0'
  s.add_runtime_dependency 'methadone'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'simplecov', '~> 0.8.2'
end
