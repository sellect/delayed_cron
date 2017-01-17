module DelayedCron
  module Scheduling

    def schedule(klass, method_name, options)
      parsed_options = parse_options(options)
      if parsed_options.is_a?(Array)
        parsed_options.each do |opts|
          processor.enqueue_delayed_cron(klass, method_name, opts)
        end
      else
        processor.enqueue_delayed_cron(klass, method_name, parsed_options)
      end
    end

    def parse_options(options)
      original_options = options
      if at = options[:at]
        options = if at.is_a?(Array)
          at.map do |at_option|
            add_interval(original_options.merge(at: at_option))
          end
        else
          add_interval(options)
        end
      end
      options
    end

    def add_interval(options)
      options[:interval] = convert_time_string_to_seconds_interval(options[:at])
      options
    end

    def convert_time_string_to_seconds_interval(scheduled_time_string)
      day_in_seconds = 60 * 60 * 24
      scheduled_time = Time.now.strftime("%Y-%m-%d #{scheduled_time_string}")
      scheduled_time = DateTime.parse(scheduled_time, false).to_time
      scheduled_time += day_in_seconds if Time.now >= scheduled_time
      scheduled_time.to_i - Time.now.to_i
    end

    def timing_opts(interval, options_at)
      timing_opts = { interval: interval }
      timing_opts.merge!(at: options_at) if options_at.present?
      timing_opts
    end

  end
end
