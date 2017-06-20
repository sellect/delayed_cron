require 'delayed_cron/cron_job'

module DelayedCron
  module Scheduling

    def schedule(klass, method_name, options)
      job = CronJob.new(options.merge(klass: klass, method_name: method_name))
      job.enqueue(processor)
    end

    def timing_opts(interval, time_zone, options_at)
      timing_opts = { interval: interval }

      timing_opts.merge!(at: options_at) if options_at.present?
      timing_opts.merge!(time_zone: time_zone) if time_zone.present?

      timing_opts
    end

  end
end
