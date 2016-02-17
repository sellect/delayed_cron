require 'spec_helper'
require 'timecop'
require 'rspec-sidekiq'
require 'hashie'

describe DelayedCron::Jobs::Sidekiq do
  let(:options)       { { interval: 123, at: "00:00:00 -0500" } }
  let(:item_hash)     { { "args" => ["SomeClass", "some_method", options] } }
  let(:item)          { Hashie::Mash.new(item: item_hash) }
  let(:item_response) { [item] }
  let(:sidekiq)       { DelayedCron::Jobs::Sidekiq }

  before do
    allow(Sidekiq::ScheduledSet).to receive(:new).and_return(item_response)
  end

  describe ".scheduled?" do
    let(:options_1) { { interval: 123, at: "11:00:00 -0500" } }
    it "checks if a job is already scheduled" do
      scheduled       = sidekiq.scheduled?("SomeClass", "some_method", options)
      not_scheduled_1 = sidekiq.scheduled?("SomeClass", "some_method", options_1)
      not_scheduled_2 = sidekiq.scheduled?("NotClass", "some_method", options)
      expect(scheduled).to eq(true)
      expect(not_scheduled_1).to eq(false)
      expect(not_scheduled_2).to eq(false)
    end
  end

end
