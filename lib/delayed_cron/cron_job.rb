module DelayedCron
  class CronJob

    def self.define_on(klass, name, options)
      new(klass, name, options).define
    end

    def initialize(klass, name, options)
      @klass   = klass
      @name    = name
      @options = options
    end

    def define
      # will be called for each cron_job :some_method found in a model
      # and for each DelayedCron.setup.cron_job in config/initializers
      schedule_cron_job
    end

    private

    def schedule_cron_job
      DelayedCron.schedule(@klass, @name, @options)
    end

  end
end
