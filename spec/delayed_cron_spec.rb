require 'spec_helper'
require 'timecop'
require 'rspec-sidekiq'

describe DelayedCron do

  describe ".setup" do
    
    it "yields self" do
      DelayedCron.setup do |config|
        DelayedCron.should == config
      end
    end

    it "sends cron jobs to define_cron_jobs" do
      DelayedCron.should_receive(:define_cron_jobs)
      setup(default_interval: 1.hour)
    end

  end

  describe ".define_cron_jobs" do

    it "should have a default_interval" do
      setup(default_interval: 1.hour)
      DelayedCron.default_interval.should_not be_nil
    end

    it "should have an array of cron_jobs" do
      setup(default_interval: 1.hour)
      DelayedCron.cron_jobs.should be_an(Array)
    end

    it "sends cron_jobs to schedule" do
      options = { default_interval: 1.hour, cron_jobs: ["SomeClass.long_method", "AnotherClass.expensive_method"] }
      options[:cron_jobs].each do |cron_job|
        klass, method_name = cron_job.split(".")
        DelayedCron.should_receive(:schedule).with(klass, method_name, { interval: options[:default_interval] })
      end
      setup(options)
    end

  end

  describe ".processor" do

    it "returns processor" do
      DelayedCron.processor.should == DelayedCron::Jobs::Sidekiq
    end

  end

  describe ".schedule" do
    it "schedules cron jobs" do
      DelayedCron.schedule("SomeClass", "long_method", { interval: 1.hour })
      expect(DelayedCron.processor).to be_processed_in :cron_job
      expect(DelayedCron.processor.jobs.size).to eq(1)
    end
  end

  describe ".process_job" do

    it "should call the cron jobs method" do
      klass = build_class("SomeClass", "long_method", {})
      klass.should_receive(:long_method)
      DelayedCron.process_job(klass.name, "long_method", {})
    end

    it "should reschedule the cron job after processing" do
      klass, name = "SomeClass", "test_method"
      build_class(klass, name)
      DelayedCron.should_receive(:schedule).with.with(klass, name, {})
      DelayedCron.process_job(klass, name, {})
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
      DelayedCron.processor.should_receive(:enqueue_delayed_cron)
                 .with("SomeClass", "long_method", { interval: adjusted_interval.to_i, at: "00:00" })
      DelayedCron.schedule("SomeClass", "long_method", { interval: interval, at: "00:00" })
    end
  end

  describe "cron_job" do
    context 'if not present' do
      it "schedules cron jobs found in a model" do
        klass, name = "SomeClass", "some_method"
        DelayedCron.should_receive(:schedule).with(klass, name, {})
        build_class(klass, name)
      end
    end
    context 'if present and true' do
      it "schedules cron jobs found in a model" do
        klass, name = "SomeClass", "some_method"
        DelayedCron.should_receive(:schedule).with(klass, name, {})
        build_class(klass, name, {if: true})
      end
    end
    context 'if present and false' do
      it "schedules cron jobs found in a model" do
        klass, name = "SomeClass", "some_method"
        DelayedCron.should_not_receive(:schedule).with(klass, name, {})
        build_class(klass, name, {if: false})
      end
    end
  end

end