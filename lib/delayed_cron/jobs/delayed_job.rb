require 'delayed_job'

module DelayedCron
  module Jobs
    class DelayedJob < Struct.new(:klass, :method_name, :options)

      if Gem.loaded_specs['delayed_job'].version >= Gem::Version.new("2.1.0") # this is available in newer versions of DelayedJob. Using the newee Job api thus.

        def self.enqueue_delayed_cron(klass, method_name, options)
          # FIXME: need to find resque's equivalent to sidekiq's perform_in method
        end

      else

        def self.enqueue_delayed_cron(klass, method_name, options)
          # FIXME: need to find resque's equivalent to sidekiq's perform_in method
        end

      end

      def perform(klass, method_name, options)
        DelayedCron.process_job(klass, method_name, options)
      end

    end
  end
end
