module DelayedCron
  class CronJob

    attr_accessor :klass, :method_name

    def initialize(options)
      self.klass = options.delete(:klass)
      self.method_name = options.delete(:method_name)

      self.raw_options = options
    end

    def enqueue(processor)
      schedule.each do |opts|
        processor.enqueue_delayed_cron(klass, method_name, opts)
      end
    end

    private

    attr_accessor :raw_options

    def schedule
      return [raw_options] if raw_options[:at].blank?

      Array.wrap(raw_options[:at]).map do |at_option|
        interval_from_at(raw_options.merge(at: at_option))
      end
    end

    def interval_from_at(options)
      interval = convert_time_string_to_seconds_interval(options[:at], options[:time_zone])
      options.merge(interval: interval)
    end

    def convert_time_string_to_seconds_interval(scheduled_time_string, zone_name)
      zone_name ||= DelayedCron.default_time_zone
      zone = Time.find_zone!(zone_name)

      if hourly?
        period_in_seconds = 60 * 60
        scheduled_time_string = "%H:#{scheduled_time_string}"
      else
        period_in_seconds = 60 * 60 * 24
      end

      scheduled_time = zone.now.strftime("%Y-%m-%d #{scheduled_time_string}")
      scheduled_time = zone.parse(scheduled_time)
      scheduled_time += period_in_seconds if zone.now >= scheduled_time
      scheduled_time.to_i - zone.now.to_i
    end

    def hourly?
      raw_options[:precision].to_s == "hourly"
    end

  end
end
