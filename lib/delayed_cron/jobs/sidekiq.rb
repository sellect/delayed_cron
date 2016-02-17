require 'sidekiq/worker'
require 'sidekiq/api'

module DelayedCron
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker
      sidekiq_options :queue => :cron_job

      def self.enqueue_delayed_cron(klass, method_name, options)
        options.symbolize_keys!
        unless do_not_enqueue?(klass, method_name, options)
          perform_in(options[:interval], klass, method_name, options)
        end
      end

      def self.do_not_enqueue?(klass, method_name, options)
        scheduled?(klass, method_name, options) ||
        enqueued?(klass, method_name, options)  ||
        retrying?(klass, method_name, options)
      end

      def self.retrying?(klass, method_name, options)
        ::Sidekiq::RetrySet.new.collect(&:item).select do |item|
          matches?(item, klass, method_name, options)
        end.present?
      end

      def self.scheduled?(klass, method_name, options)
        ::Sidekiq::ScheduledSet.new.collect(&:item).select do |item|
          matches?(item, klass, method_name, options)
        end.present?
      end

      def self.enqueued?(klass, method_name, options)
        ::Sidekiq::Queue.new("cron_job").collect(&:item).select do |item|
          matches?(item, klass, method_name, options)
        end.present?
      end

      def self.matches?(item, klass, method_name, options)
        class_and_method_match?(item["args"], klass, method_name) &&
        at_match?(item["args"][2], options)
      end

      def self.at_match?(arg_options, options)
        return true unless !!arg_options["at"] && !!options[:at]
        arg_options["at"] == options[:at]
      end

      def self.class_and_method_match?(args, klass, method_name)
        args[0] == klass && args[1] == method_name.to_s
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end

# "Kwi::Cron", "get_inventory", {"interval"=>81886, "at"=>"08:30:00 -0500"}
