require 'sidekiq/worker'
require 'sidekiq/api'

module DelayedCron
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker
      sidekiq_options :queue => :cron_job

      def self.enqueue_delayed_cron(klass, method_name, options)
        unless scheduled?(klass, method_name)
          options.symbolize_keys!
          perform_in(options[:interval], klass, method_name, options)
        end
      end

      def self.scheduled?(klass, method_name)
        items = []
        ::Sidekiq::ScheduledSet.new.each { |job| items << job.item }
        items.select do |item|
          item["args"][0] == klass &&
          item["args"][1] == method_name.to_s
        end.present?
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end
