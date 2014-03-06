require 'delayed_cron/jobs'
require 'delayed_cron/railtie'

module DelayedCron

  class << self

    def detect_background_task
      return DelayedCron::Jobs::DelayedJob if defined? ::Delayed::Job
      return DelayedCron::Jobs::Resque     if defined? ::Resque
      return DelayedCron::Jobs::Sidekiq    if defined? ::Sidekiq
    end

  end

  module Glue
    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    end
  end

  module ClassMethods

    def cron_job(name, options = {})
      CronJob.define_on(self, name, options)
    end

  end

  module InstanceMethods

  end

end
