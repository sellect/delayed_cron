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
      expect(DelayedCron.processor).to have(1).jobs
    end
  end

  describe ".process_job" do
    it "should call the cron jobs method" do
      klass = build_class("SomeClass", "long_method", {})
      klass.should_receive(:long_method)
      DelayedCron.process_job(klass.name, "long_method", {})
    end
  end

  describe ".beginning_of_day" do
    it "returns the beginning of the day for the interval" do
      pending
    end
  end

  describe ".adjust_interval" do
    it "adjusts the interval based on the :at option" do
      pending
    end
  end

  describe "cron_job" do
    it "schedules cron jobs found in a model" do
      pending
    end
  end

end