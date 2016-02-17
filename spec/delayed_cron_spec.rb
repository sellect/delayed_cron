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

    let(:options) do
      {
        default_interval: 1.hour,
        cron_jobs: [
          "SomeClass.long_method",
          { job: "AnotherClass.expensive_method", interval: 1.hour }
        ]
      }
    end

    it "sends cron_jobs to schedule" do
      options[:cron_jobs].each do |cron_job|
        job_is_hash = cron_job.is_a?(Hash)
        klass, method_name = job_is_hash ? cron_job[:job].split(".") : cron_job.split(".")
        interval = job_is_hash ? cron_job[:interval] : options[:default_interval]
        DelayedCron.should_receive(:schedule).with(klass, method_name, { interval: interval })
      end
      setup(options)
    end

  end

  describe ".processor" do

    it "returns processor" do
      DelayedCron.processor.should == DelayedCron::Jobs::Sidekiq
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
