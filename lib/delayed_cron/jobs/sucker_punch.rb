require 'sucker_punch'

module DelayedCron
  module Jobs
    class SuckerPunch
      include ::SuckerPunch::Job

      def self.enqueue_delayed_cron(klass, method_name, options)
        unless scheduled?(klass)
          options.symbolize_keys!
          self.new.later(options[:interval], klass, method_name, options)
        end
      end

      def self.scheduled?(klass)
        ::SuckerPunch::Queue.new(klass).registered?
      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

      def later(sec, *args)
        after(sec) { perform(*args) }
      end

    end
  end
end
