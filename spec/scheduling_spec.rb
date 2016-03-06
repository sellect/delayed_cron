require 'spec_helper'
require 'timecop'
require 'rspec-sidekiq'

describe DelayedCron::Scheduling do

  describe ".schedule" do
    it "schedules cron jobs" do
      DelayedCron.schedule("SomeClass", "long_method", { interval: 1.hour })
      expect(DelayedCron.processor).to be_processed_in :cron_job
      expect(DelayedCron.processor.jobs.size).to eq(1)
    end
  end

  describe ".parse_options" do
    let(:at_string) { { interval: 1.day, at: "00:00:00 -0500" } }
    let(:at_array)  { { interval: 1.day, at: ["00:00:00 -0500", "01:00:00 -0500"]} }
    let(:no_at)     { { interval: 1.day } }

    it "parses options `at` option as string" do
      expect(DelayedCron.parse_options(at_string)[:at]).to eq("00:00:00 -0500")
    end

    it "parses options `at` option as array" do
      expected_options_array = [
        { interval: 123, at: "00:00:00 -0500" },
        { interval: 123, at: "01:00:00 -0500" }
      ]
      expect(DelayedCron.parse_options(at_array)[0][:at]).to eq("00:00:00 -0500")
      expect(DelayedCron.parse_options(at_array)[1][:at]).to eq("01:00:00 -0500")
    end

    it "does not change options if `at` is not present" do
      expect(DelayedCron.parse_options(no_at)).to eq(no_at)
    end
  end

  describe ".timing_opts" do

    let(:options) do
      { interval: 1.day, at: "05:00:00 -0400" }
    end

    it "collects the timing options" do
      interval = { interval: 1.day }
      timing_opts = DelayedCron.timing_opts(options[:interval], options[:at])
      expect(timing_opts).to eq(options)
      expect(timing_opts).not_to eq(interval)
    end
  end

  describe ".beginning_of_day" do
    it "returns the beginning of the day for the interval" do
      seconds = 2.days.to_i
      beginning_of_day_2_days_from_now = DelayedCron.beginning_of_day(seconds)
      expect(beginning_of_day_2_days_from_now).to be <  2.days.from_now
      expect(beginning_of_day_2_days_from_now).to be >  1.day.from_now
    end
  end

  describe ".adjust_interval" do
    it "adjusts the interval based on the :at option" do
      # Set Time.now to January 1, 2014 12:00:00 PM
      Timecop.freeze(Time.local(2014, 1, 1, 12, 0, 0))
      interval = 9.days
      adjusted_interval = interval - 12.hours
      expect(DelayedCron.processor).to receive(:enqueue_delayed_cron)
                 .with("SomeClass", "long_method", { interval: adjusted_interval.to_i, at: "00:00" })
      DelayedCron.schedule("SomeClass", "long_method", { interval: interval, at: "00:00" })
    end
  end

end
