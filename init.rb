require File.join(File.dirname(__FILE__), "lib", "delayed_cron")
require 'delayed_cron/railtie'

DelayedCron::Railtie.insert
