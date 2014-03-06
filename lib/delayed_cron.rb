require 'delayed_cron/jobs'
require 'delayed_cron/railtie'
require 'delayed_cron/cron_job'

module DelayedCron

  mattr_accessor :interval, :cron_jobs

  class << self

    def setup
      yield self
      define_cron_jobs
    end

    def define_cron_jobs
      cron_jobs.each do |job|
        klass = job.split(".").first.constantize
        name  = job.split(".").last
        CronJob.define_on(klass, name, { interval: interval })
      end
    end

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
