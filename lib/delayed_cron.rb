require 'active_support/all'
require 'delayed_cron/jobs'
require 'delayed_cron/scheduling'
require 'delayed_cron/railtie'

module DelayedCron

  mattr_accessor :default_interval, :default_time_zone, :cron_jobs

  class << self

    include DelayedCron::Scheduling

    def setup
      yield self
      define_cron_jobs
    end

    def define_cron_jobs
      return false unless cron_jobs.present?

      cron_jobs.each do |job|
        job = job.is_a?(Hash) ? job : { job: job }
        klass, name = job[:job].split(".")
        # TODO: raise error if interval is not set
        options     = timing_opts(job)
        DelayedCron.schedule(klass, name, options)
      end
    end

    def processor
      return DelayedCron::Jobs::DelayedJob  if defined? ::Delayed::Job
      return DelayedCron::Jobs::Resque      if defined? ::Resque
      return DelayedCron::Jobs::Sidekiq     if defined? ::Sidekiq
      return DelayedCron::Jobs::SuckerPunch if defined? ::SuckerPunch
    end

    def process_job(klass, method_name, options)
      # TODO: add ability to send args to klass method
      klass.constantize.send(method_name)
      symbolized_options = options.collect{|k,v| [k.to_sym, v]}.to_h
      schedule(klass, method_name, symbolized_options)
    end

    def default_time_zone
      @@default_time_zone || "Eastern Time (US & Canada)"
    end

  end

  module Glue
    def self.included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods

    def cron_job(name, options = { interval: DelayedCron.default_interval })
      return false if options.delete(:if) == false
      DelayedCron.schedule(self.name.to_s, name, options)
    end

  end

end
