require 'delayed_cron/cron_job'

module DelayedCron
  module Scheduling

    def schedule(klass, method_name, options)
      job = CronJob.new(options.merge(klass: klass, method_name: method_name))
      job.enqueue(processor)
    end

    def timing_opts(job)
      {
        interval: job[:interval] || default_interval,
        time_zone: job[:time_zone],
        precision: job[:precision],
        at: job[:at]
      }.select { |_, value| !value.nil? }
    end

  end
end
