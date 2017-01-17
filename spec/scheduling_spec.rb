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

  describe ".add_interval" do
    it 'adds an interval key and value to the options hash' do
      options = DelayedCron.add_interval(at: '12:00:00 -0500')
      expect(options).to include(:interval)
    end
  end

  describe ".convert_time_string_to_seconds_interval" do
    let(:next_occurrence) do
      DelayedCron.convert_time_string_to_seconds_interval(scheduled_time)
    end
    # Set Time.now to January 1, 2014 12:00:00 PM
    before { Timecop.freeze(Time.local(2014, 1, 1, 12, 0, 0)) }
    context "next occurrence is today" do
      let(:known_interval) { 3600 }
      let(:scheduled_time) { "13:00:00 -0500" }
      it "converts a time string to seconds" do
        expect(next_occurrence).to be(known_interval)
      end
    end

    context "next occurrence is tomorrow" do
      let(:known_interval) { 82800 }
      let(:scheduled_time) { "11:00:00 -0500" }
      it "converts a time string to seconds" do
        expect(next_occurrence).to be(known_interval)
      end
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

end
