require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

RSpec::Core::RakeTask.new(:spec)

task :default => :spec