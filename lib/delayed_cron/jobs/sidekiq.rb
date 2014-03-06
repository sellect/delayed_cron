require 'sidekiq/worker'

module DelayedCron
  module Jobs
    class Sidekiq
      include ::Sidekiq::Worker
      sidekiq_options :queue => :cron_job

      def self.enqueue_delayed_cron(instance_klass, instance_id, attachment_name)
        perform_async(instance_klass, instance_id, attachment_name)
      end

      def perform(instance_klass, instance_id, attachment_name)
        DelayedCron.process_job(instance_klass, instance_id, attachment_name)
      end
    end
  end
end
