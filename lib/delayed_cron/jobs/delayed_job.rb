require 'delayed_job'

module DelayedCron
  module Jobs
    class DelayedJob < Struct.new(:klass, :method_name, :options)

      def self.enqueue_delayed_cron(klass, method_name, options)
        unless scheduled?(klass, method_name)
          options.symbolize_keys!
          ::Delayed::Job.enqueue(
            :payload_object => new(klass, method_name, options),
            :run_at => Time.now + options[:interval],
            :queue => :cron_job
          )
        end
      end

      def self.scheduled?(klass, method_name)
        scheduled = false
        ::Delayed::Job.where(:queue => :cron_job).each do |job|
          obj = YAML.load_dj(job.handler)
          scheduled = true if obj["klass"] == klass && obj["method_name"] == method_name
        end
        scheduled
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end
