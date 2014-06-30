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
        klass, name = job.split(".")
        # TODO: raise error if interval is not set from config
        DelayedCron.schedule(klass, name, { interval: default_interval })
      end
    end

    def processor
      return DelayedCron::Jobs::DelayedJob  if defined? ::Delayed::Job
      return DelayedCron::Jobs::Resque      if defined? ::Resque
      return DelayedCron::Jobs::Sidekiq     if defined? ::Sidekiq
      return DelayedCron::Jobs::SuckerPunch if defined? ::SuckerPunch
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
      (Time.now + seconds).beginning_of_day
    end

    def adjust_interval(date, time_string)
      adjusted_date(date, time_string).to_i - Time.now.to_i
    end

    def adjusted_date(date, time_string)
      time = parse_time(time_string.split(/:|\ /).map(&:to_i))
      DateTime.civil(date.year, date.month, date.day, time[:hours], time[:mins], time[:secs], Rational(time[:tz], 2400))
    end

    def parse_time(time_array)
      { 
        hours: time_array[0], 
        mins:  time_array[1], 
        secs:  time_array[2] || 0, 
        tz:    time_array[3] || Time.now.strftime("%z").to_i
      }
    end

  end

  module Glue
    def self.included(base)
      base.extend(ClassMethods)
    end
  end

  module ClassMethods

    def cron_job(name, options = { interval: DelayedCron.default_interval })
      return false unless options.delete(:if)
      DelayedCron.schedule(self.name.to_s, name, options)
    end

  end

end
