require 'sidekiq/worker'

module DelayedCron
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker
      sidekiq_options :queue => :cron_job

      def self.enqueue_delayed_cron(klass, method_name, options)
        options.symbolize_keys!
        perform_in(options[:interval], klass, method_name, options)
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end
