require 'delayed_job'

module DelayedCron
  module Jobs
    class DelayedJob < Struct.new(:klass, :method_name, :options)

      def self.enqueue_delayed_cron(klass, method_name, options)
        unless scheduled?(klass, method_name)
          # TODO: need to find delayed_job's equivalent to sidekiq's perform_in method
        end
      end

      def self.scheduled?(klass, method_name)
        # TODO: returns true if job is already scheduled
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end
