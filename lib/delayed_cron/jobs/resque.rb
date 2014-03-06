require 'resque'

module DelayedCron
  module Jobs
    class Resque
      @queue = :cron_job

      def self.enqueue_delayed_cron(instance_klass, instance_id, attachment_name)
        ::Resque.enqueue(self, instance_klass, instance_id, attachment_name)
      end

      def self.perform(instance_klass, instance_id, attachment_name)
        DelayedCron.process_job(instance_klass, instance_id, attachment_name)
      end
    end
  end
end
