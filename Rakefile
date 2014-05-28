require 'rspec/core/rake_task'

task :default => [:rubocop, :spec]

RSpec::Core::RakeTask.new(:spec) do |task|
  # Set a bogus Fog credential, otherwise it's possible for the unit
  # tests to accidentially run (and succeed against!) an actual
  # environment, if Fog connection is not stubbed correctly.
  ENV['FOG_CREDENTIAL'] = 'random_nonsense_owiejfoweijf'
  ENV['COVERAGE'] = 'true'
  task.pattern = FileList['spec/vcloud/**/*_spec.rb']
end

RSpec::Core::RakeTask.new('integration') do |t|
  t.pattern = FileList['spec/integration/**/*_spec.rb']
end

require "gem_publisher"
task :publish_gem do
  gem = GemPublisher.publish_if_updated("vcloud-core.gemspec", :rubygems)
  puts "Published #{gem}" if gem
end

require 'rubocop/rake_task'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.options = ['--lint']
end
