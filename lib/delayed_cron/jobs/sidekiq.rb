require 'sidekiq/worker'
require 'sidekiq/api'

module DelayedCron
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker
      sidekiq_options :queue => :cron_job

      def self.enqueue_delayed_cron(klass, method_name, options)
        unless do_not_enqueue?(klass, method_name)
          options.symbolize_keys!
          perform_in(options[:interval], klass, method_name, options)
        end
      end

      def self.do_not_enqueue?(klass, method_name)
        scheduled?(klass, method_name) ||
        enqueued?(klass, method_name)  ||
        retrying?(klass, method_name)
      end

      def self.retrying?(klass, method_name)
        ::Sidekiq::RetrySet.new.collect(&:item).select do |item|
          matches_kass_and_method?(item, klass, method_name)
        end.present?
      end

      def self.scheduled?(klass, method_name)
        ::Sidekiq::ScheduledSet.new.collect(&:item).select do |item|
          matches_kass_and_method?(item, klass, method_name)
        end.present?
      end

      def self.enqueued?(klass, method_name)
        ::Sidekiq::Queue.new("cron_job").collect(&:item).select do |item|
          matches_kass_and_method?(item, klass, method_name)
        end.present?
      end

      def self.matches_kass_and_method?(item, klass, method_name)
        item["args"][0] == klass && item["args"][1] == method_name.to_s
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end
