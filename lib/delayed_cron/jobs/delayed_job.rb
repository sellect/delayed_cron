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
        ::Delayed::Job.all.each do |job|
          obj = YAML.load(job.handler)
          scheduled = true if obj["object"] == klass && obj["method_name"] == method_name.to_s
        end
        scheduled ||= false
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end
