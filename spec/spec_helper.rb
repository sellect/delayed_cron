require 'bundler/setup'
Bundler.setup

require 'rails'
require 'active_record'
require 'timecop'
require 'sidekiq'
require 'rspec-sidekiq'

require 'delayed_cron/railtie'
DelayedCron::Railtie.insert


RSpec.configure do |config|

end

def setup(options)
  DelayedCron.setup do |config|
    config.default_interval = options[:default_interval]
    config.cron_jobs = options[:cron_jobs] || []
  end
end

def build_class(class_name, name, options)
  # setup class and include delayed_cron
  options ||= {}
  ActiveRecord::Base.send(:include, DelayedCron::Glue)
  Object.send(:remove_const, class_name) rescue nil

  # Set class as a constant
  klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))

  # Setup class with paperclip and delayed paperclip
  klass.class_eval do
    include DelayedCron::Glue

    cron_job name, options

  end
  
  klass
end