require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new :cop
RSpec::Core::RakeTask.new :spec

#running rake will make it run rubocop and rspec in one command
task default: [:cop, :spec]