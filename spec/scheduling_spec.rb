require 'spec_helper'
require 'timecop'
require 'rspec-sidekiq'

describe DelayedCron::Scheduling do

  describe ".schedule" do
    it "schedules cron jobs" do
      DelayedCron.schedule("SomeClass", "long_method", { interval: 1.hour })
      expect(DelayedCron.processor).to be_processed_in :cron_job
      expect(DelayedCron.processor.jobs.size).to eq(1)

      expect(DelayedCron.processor.jobs.last["args"])
        .to eq(["SomeClass", "long_method", { "interval" => 1.hour.to_s }])
    end
  end

  describe ".timing_opts" do

    let(:options) do
      { interval: 1.day, at: "05:00:00 -0400" }
    end

    it "collects the timing options" do
      interval = { interval: 1.day }
      timing_opts = DelayedCron.timing_opts(options[:interval], nil, options[:at])
      expect(timing_opts).to eq(options)
      expect(timing_opts).not_to eq(interval)
    end

    it "passes time_zone through" do
      options_with_zone = options.merge(time_zone: "UTC")
      timing_opts = DelayedCron.timing_opts(options[:interval], "UTC", options[:at])
      expect(timing_opts).to eq(options_with_zone)
    end
  end

end
