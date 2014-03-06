require 'resque'

module DelayedCron
  module Jobs
    class Resque
      @queue = :cron_job

      def self.enqueue_delayed_cron(klass, method_name, options)
        # FIXME: need to find resque's equivalent to sidekiq's perform_in method
      end

      def self.perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end
    end
  end
end
