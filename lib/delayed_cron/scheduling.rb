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
      date = beginning_of_day(options[:interval].to_i)
      options[:interval] = adjust_interval(date, options[:at])
      options
    end

    def timing_opts(interval, options_at)
      timing_opts = { interval: interval }
      timing_opts.merge!(at: options_at) if options_at.present?
      timing_opts
    end

    def beginning_of_day(seconds)
      (Time.now + seconds).beginning_of_day
    end

    def adjust_interval(date, time_string)
      adjusted_date(date, time_string).to_i - Time.now.to_i
    end

    def adjusted_date(date, time_string)
      time = parse_time(time_string.split(/:|\ /).map(&:to_i))
      DateTime.civil(
        date.year,
        date.month,
        date.day,
        time[:hours],
        time[:mins],
        time[:secs],
        Rational(time[:tz], 2400)
      )
    end

    def parse_time(time_array)
      {
        hours: time_array[0],
        mins:  time_array[1],
        secs:  time_array[2] || 0,
        tz:    time_array[3] || Time.now.strftime("%z").to_i
      }
    end

  end
end
