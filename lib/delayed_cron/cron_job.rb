module DelayedCron
  class CronJob

    def self.define_on(klass, name, options)
      new(klass, name, options).define
    end

    def initialize(klass, name, options)
      @klass = klass
      @name = name
      @options = options
    end

    def define
      # call private methods
    end

    private

    # private methods

  end
end
