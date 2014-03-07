require 'delayed_cron/jobs'
require 'delayed_cron/railtie'

module DelayedCron

  mattr_accessor :default_interval, :cron_jobs

  class << self

    def setup
      yield self
      define_cron_jobs
    end

    def define_cron_jobs
      return false unless cron_jobs.present?
      cron_jobs.each do |job|
        klass = job.split(".").first
        name  = job.split(".").last.to_sym
        # TODO: raise error if interval is not set from config
        DelayedCron.schedule(klass, name, { interval: default_interval })
      end
    end

    def processor
      return DelayedCron::Jobs::DelayedJob if defined? ::Delayed::Job
      return DelayedCron::Jobs::Resque     if defined? ::Resque
      return DelayedCron::Jobs::Sidekiq    if defined? ::Sidekiq
    end

    def schedule(klass, method_name, options)
      processor.enqueue_delayed_cron(klass, method_name, options)
    end

    def process_job(klass, method_name, options)
      # TODO: add ability to send args to klass method
      klass.constantize.send(method_name)
      schedule(klass, method_name, options)
    end

  end

  module Glue
    def self.included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods

    def cron_job(name, options = { interval: DelayedCron.default_interval })
      DelayedCron.schedule(self.name.to_s, name, options)
    end

  end

end
