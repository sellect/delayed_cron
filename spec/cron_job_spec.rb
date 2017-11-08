require "spec_helper"

module DelayedCron
  RSpec.describe CronJob do
    describe "#new" do
      let(:job) { described_class.new(klass: "Foo", method_name: "bar") }

      it "stores klass" do
        expect(job.klass).to eq "Foo"
      end

      it "stores method_name" do
        expect(job.method_name).to eq "bar"
      end
    end

    describe "#enqueue" do
      let(:job) { described_class.new(klass: "Foo", method_name: "bar", interval: 3600) }
      let(:processor) { class_double(Jobs::Sidekiq) }

      before { Timecop.freeze(Time.utc(2014, 1, 1, 12, 0, 0)) }

      it "passes interval through for periodic jobs" do
        job = described_class.new(klass: "Foo", method_name: "bar", interval: 3600)

        expect(processor).to receive(:enqueue_delayed_cron)
          .with("Foo", "bar", interval: 3600)

        job.enqueue(processor)
      end

      it "converts :at to interval" do
        job = described_class.new(klass: "Foo", method_name: "bar", interval: 3600, at: "10:00:00")

        expect(processor).to receive(:enqueue_delayed_cron)
          .with("Foo", "bar", interval: 10800, at: "10:00:00")

        job.enqueue(processor)
      end

      it "enqueues multiple jobs from array of :at times" do
        job = described_class.new(
          klass: "Foo",
          method_name: "bar",
          interval: 3600,
          at: ["10:00:00", "09:00:00"]
        )

        expect(processor).to receive(:enqueue_delayed_cron)
          .with("Foo", "bar", interval: 10800, at: "10:00:00")
        expect(processor).to receive(:enqueue_delayed_cron)
          .with("Foo", "bar", interval: 7200, at: "09:00:00")

        job.enqueue(processor)
      end

      it 'respects time zone parameter' do
        job = described_class.new(
          klass: "Foo",
          method_name: "bar",
          interval: 3600,
          at: "13:00:00",
          time_zone: "UTC"
        )

        expect(processor).to receive(:enqueue_delayed_cron)
          .with("Foo", "bar", interval: 3600, at: "13:00:00", time_zone: "UTC")

        job.enqueue(processor)
      end
    end

    describe ".convert_time_string_to_seconds_interval" do
      let(:job) { described_class.new({}) }

      let(:next_occurrence) do
        job.send(:convert_time_string_to_seconds_interval, scheduled_time, "Eastern Time (US & Canada)")
      end
      let(:zone) { Time.find_zone!("Eastern Time (US & Canada)") }

      # Set Time.now to January 1, 2014 12:00:00 PM
      before { Timecop.freeze(Time.utc(2014, 1, 1, 12, 0, 0)) }

      context "next occurrence is today" do
        let(:known_interval) { 21600 }
        let(:scheduled_time) { "13:00:00 -0500" }
        it "converts a time string to seconds" do
          expect(next_occurrence).to be(known_interval)
        end
      end

      context "next occurrence is tomorrow" do
        let(:known_interval) { 14400 }
        let(:scheduled_time) { "11:00:00 -0500" }
        it "converts a time string to seconds" do
          expect(next_occurrence).to be(known_interval)
        end
      end

      context "with time zone" do
        let(:known_interval) { 14400 }
        let(:scheduled_time) { "11:00:00 Eastern Time (US & Canada)" }
        it "converts a time string to seconds" do
          expect(next_occurrence).to be(known_interval)
        end
      end

      context "with DST" do
        let(:known_interval) { 14400 }
        let(:scheduled_time) { "11:00:00 -0500" }
        it "converts a time string to seconds" do
          Timecop.freeze(Time.utc(2014, 6, 1, 12, 0, 0))

          expect(next_occurrence).to be(known_interval)
        end
      end

      context "hourly interval" do
        let(:job) { described_class.new(precision: :hourly) }
        let(:known_interval) { 300 }

        let(:scheduled_time) { "05:00 -0500" }
        it "converts a time string to seconds" do
          expect(next_occurrence).to be(known_interval)
        end
      end

      context "next hour" do
        let(:job) { described_class.new(precision: :hourly) }
        let(:known_interval) { 300 }

        let(:scheduled_time) { "00:00" }
        it "converts a time string to seconds" do
          Timecop.freeze(Time.utc(2014, 1, 1, 12, 55, 0))

          expect(next_occurrence).to be(known_interval)
        end

        it 'handles DST end' do
          time = zone.local(2017, 11, 5, 1, 0) + 1.hour # ST start
          Timecop.freeze(time)

          expect(next_occurrence).to eq(1.hour.to_i)
        end
      end

      context 'DST ends before next time' do
        let(:scheduled_time) { "00:05:00" }

        it 'adds an extra hour to the offset' do
          time = zone.local(2017, 11, 5, 0, 5)
          Timecop.freeze(time)

          expect(next_occurrence).to eq(25.hours.to_i)
        end
      end

      context 'calculation is on day of DST end' do
        let(:scheduled_time) { "00:05:00" }

        it 'still calculates correct offset' do
          time = zone.local(2017, 11, 5, 23, 5)
          Timecop.freeze(time)

          expect(next_occurrence).to eq(1.hour.to_i)
        end
      end

    end
  end
end
