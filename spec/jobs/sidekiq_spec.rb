require 'spec_helper'
require 'timecop'
require 'rspec-sidekiq'
require 'hashie'

describe DelayedCron::Jobs::Sidekiq do
  let(:options)       { { interval: 123, at: "00:00:00 -0500" } }
  let(:options_1)     { { interval: 123, at: "11:00:00 -0500" } }
  let(:item_hash)     { { "args" => ["SomeClass", "some_method", options] } }
  let(:item)          { Hashie::Mash.new(item: item_hash) }
  let(:item_response) { [item] }
  let(:sidekiq)       { DelayedCron::Jobs::Sidekiq }

  before do
    allow(Sidekiq::RetrySet).to receive(:new).and_return(item_response)
    allow(Sidekiq::ScheduledSet).to receive(:new).and_return(item_response)
    allow(Sidekiq::Queue).to receive(:new).with("cron_job").and_return(item_response)
  end

  describe ".enqueue_delayed_cron" do
  end

  describe ".do_not_enqueue?" do
  end

  describe ".retrying?" do
    it "returns true if a job is retrying" do
      retrying = sidekiq.retrying?("SomeClass", "some_method", options)
      expect(retrying).to eq(true)
    end

    it "returns false if a job is not retrying" do
      not_retrying = sidekiq.retrying?("NotClass", "some_method", options)
      expect(not_retrying).to eq(false)
    end

    it "returns false if a job is retrying, but for a different time" do
      not_retrying = sidekiq.retrying?("SomeClass", "some_method", options_1)
      expect(not_retrying).to eq(false)
    end
  end

  describe ".scheduled?" do
    it "returns true if a job is scheduled" do
      scheduled = sidekiq.scheduled?("SomeClass", "some_method", options)
      expect(scheduled).to eq(true)
    end

    it "returns false if a job is not scheduled" do
      not_scheduled = sidekiq.scheduled?("NotClass", "some_method", options)
      expect(not_scheduled).to eq(false)
    end

    it "returns false if a job is scheduled, but for a different time" do
      not_scheduled = sidekiq.scheduled?("SomeClass", "some_method", options_1)
      expect(not_scheduled).to eq(false)
    end
  end

  describe ".enqueued?" do
    it "returns true if a job is already enqueued" do
      enqueued = sidekiq.enqueued?("SomeClass", "some_method", options)
      expect(enqueued).to eq(true)
    end

    it "returns false if a job is not enqueued" do
      not_enqueued = sidekiq.enqueued?("NotClass", "some_method", options)
      expect(not_enqueued).to eq(false)
    end

    it "returns false if a job is enqueued, but for a different time" do
      not_enqueued = sidekiq.enqueued?("SomeClass", "some_method", options_1)
      expect(not_enqueued).to eq(false)
    end
  end

  describe ".matches?" do
  end

  describe ".at_match?" do
  end

  describe ".class_and_method_match?" do
  end

  describe "#perform" do
  end

end
