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
      if options[:at]
        options[:interval] = adjust_interval(beginning_of_day(options[:interval].to_i), options[:at])
      end
      processor.enqueue_delayed_cron(klass, method_name, options)
    end

    def process_job(klass, method_name, options)
      # TODO: add ability to send args to klass method
      klass.constantize.send(method_name)
      schedule(klass, method_name, options)
    end

    def beginning_of_day(seconds)
      # returns the beginning of the day for the interval
      (Time.now + seconds).beginning_of_day
    end

    def adjust_interval(date, time_string)
      time = time_string.split(/:|\ /).map(&:to_i)
      tz   = time[3] || Time.now.strftime("%z").to_i
      secs = time[2] || 0
      hours, mins = time[0], time[1]
      adjusted_date = DateTime.civil(date.year, date.month, date.day, hours, mins, secs, Rational(tz, 2400))
      adjusted_date.to_i - Time.now.to_i
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
