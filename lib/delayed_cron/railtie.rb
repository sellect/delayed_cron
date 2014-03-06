require 'delayed_cron'

module DelayedCron

  if defined? Rails::Railtie
    require 'rails'

    # On initialzation, include DelayedCron
    class Railtie < Rails::Railtie
      initializer 'delayed_cron.insert_into_active_record' do
        ActiveSupport.on_load :active_record do
          DelayedCron::Railtie.insert
        end
      end
    end
  end

  class Railtie

    # Glue includes DelayedCron Class Methods into ActiveRecord
    def self.insert
      ActiveRecord::Base.send(:include, DelayedCron::Glue)
    end

  end

end
