require 'spec_helper'

module Geonames
  describe Timezone do
    let(:timezone) { Timezone.new }

    describe "initialization" do
      it "creates a new Timezone instance" do
        expect(timezone).to be_a(Timezone)
      end

      it "initializes with nil attributes" do
        expect(timezone.timezone_id).to be_nil
        expect(timezone.gmt_offset).to be_nil
        expect(timezone.dst_offset).to be_nil
      end
    end

    describe "attribute accessors" do
      describe "#timezone_id" do
        it "allows setting and getting timezone_id" do
          timezone.timezone_id = "America/Toronto"
          expect(timezone.timezone_id).to eq("America/Toronto")
        end

        it "accepts nil values" do
          timezone.timezone_id = "America/New_York"
          timezone.timezone_id = nil
          expect(timezone.timezone_id).to be_nil
        end

        it "accepts various timezone formats" do
          valid_timezones = [
            "America/Toronto",
            "Europe/London",
            "Asia/Tokyo",
            "UTC",
            "GMT",
            "America/Los_Angeles"
          ]

          valid_timezones.each do |tz|
            timezone.timezone_id = tz
            expect(timezone.timezone_id).to eq(tz)
          end
        end
      end

      describe "#gmt_offset" do
        it "allows setting and getting gmt_offset" do
          timezone.gmt_offset = -5.0
          expect(timezone.gmt_offset).to eq(-5.0)
        end

        it "accepts positive offsets" do
          timezone.gmt_offset = 9.5
          expect(timezone.gmt_offset).to eq(9.5)
        end

        it "accepts negative offsets" do
          timezone.gmt_offset = -8.0
          expect(timezone.gmt_offset).to eq(-8.0)
        end

        it "accepts zero offset" do
          timezone.gmt_offset = 0.0
          expect(timezone.gmt_offset).to eq(0.0)
        end

        it "accepts nil values" do
          timezone.gmt_offset = -5.0
          timezone.gmt_offset = nil
          expect(timezone.gmt_offset).to be_nil
        end

        it "accepts integer values" do
          timezone.gmt_offset = -5
          expect(timezone.gmt_offset).to eq(-5)
        end

        it "accepts fractional hour offsets" do
          timezone.gmt_offset = 5.5
          expect(timezone.gmt_offset).to eq(5.5)
        end

        it "accepts extreme offsets" do
          timezone.gmt_offset = -12.0
          expect(timezone.gmt_offset).to eq(-12.0)

          timezone.gmt_offset = 14.0
          expect(timezone.gmt_offset).to eq(14.0)
        end
      end

      describe "#dst_offset" do
        it "allows setting and getting dst_offset" do
          timezone.dst_offset = -4.0
          expect(timezone.dst_offset).to eq(-4.0)
        end

        it "accepts positive offsets" do
          timezone.dst_offset = 10.0
          expect(timezone.dst_offset).to eq(10.0)
        end

        it "accepts negative offsets" do
          timezone.dst_offset = -7.0
          expect(timezone.dst_offset).to eq(-7.0)
        end

        it "accepts zero offset" do
          timezone.dst_offset = 0.0
          expect(timezone.dst_offset).to eq(0.0)
        end

        it "accepts nil values" do
          timezone.dst_offset = -4.0
          timezone.dst_offset = nil
          expect(timezone.dst_offset).to be_nil
        end

        it "accepts integer values" do
          timezone.dst_offset = -4
          expect(timezone.dst_offset).to eq(-4)
        end

        it "accepts fractional hour offsets" do
          timezone.dst_offset = -3.5
          expect(timezone.dst_offset).to eq(-3.5)
        end
      end
    end

    describe "attribute independence" do
      it "allows setting all attributes independently" do
        timezone.timezone_id = "America/Toronto"
        timezone.gmt_offset = -5.0
        timezone.dst_offset = -4.0

        expect(timezone.timezone_id).to eq("America/Toronto")
        expect(timezone.gmt_offset).to eq(-5.0)
        expect(timezone.dst_offset).to eq(-4.0)
      end

      it "does not affect other instances" do
        timezone1 = Timezone.new
        timezone2 = Timezone.new

        timezone1.timezone_id = "America/Toronto"
        timezone1.gmt_offset = -5.0

        expect(timezone2.timezone_id).to be_nil
        expect(timezone2.gmt_offset).to be_nil
      end
    end

    describe "#tzinfo" do
      context "when TZInfo is available" do
        before do
          stub_const("TZInfo::Timezone", Class.new do
            def self.get(identifier)
              new(identifier)
            end

            def initialize(identifier)
              @identifier = identifier
            end

            attr_reader :identifier
          end)
        end

        it "returns a TZInfo::Timezone object" do
          timezone.timezone_id = "America/Toronto"
          result = timezone.tzinfo
          expect(result).to be_a(TZInfo::Timezone)
          expect(result.identifier).to eq("America/Toronto")
        end

        it "passes the timezone_id to TZInfo::Timezone.get" do
          timezone.timezone_id = "Europe/London"
          expect(TZInfo::Timezone).to receive(:get).with("Europe/London").and_call_original
          timezone.tzinfo
        end

        it "works with different timezone identifiers" do
          timezones = ["UTC", "America/New_York", "Asia/Tokyo"]
          
          timezones.each do |tz_id|
            timezone.timezone_id = tz_id
            result = timezone.tzinfo
            expect(result.identifier).to eq(tz_id)
          end
        end
      end

      context "when TZInfo is not available" do
        before do
          hide_const("TZInfo")
        end

        it "raises NameError when TZInfo is not loaded" do
          timezone.timezone_id = "America/Toronto"
          expect {
            timezone.tzinfo
          }.to raise_error(NameError, /uninitialized constant.*TZInfo/)
        end
      end

      context "when timezone_id is nil" do
        before do
          stub_const("TZInfo::Timezone", Class.new do
            def self.get(identifier)
              raise ArgumentError, "timezone identifier cannot be nil" if identifier.nil?
              new(identifier)
            end

            def initialize(identifier)
              @identifier = identifier
            end

            attr_reader :identifier
          end)
        end

        it "passes nil to TZInfo::Timezone.get" do
          timezone.timezone_id = nil
          expect {
            timezone.tzinfo
          }.to raise_error(ArgumentError, /timezone identifier cannot be nil/)
        end
      end

      context "when timezone_id is invalid" do
        before do
          stub_const("TZInfo::Timezone", Class.new do
            def self.get(identifier)
              raise TZInfo::InvalidTimezoneIdentifier, "Invalid timezone: #{identifier}"
            end
          end)
          
          stub_const("TZInfo::InvalidTimezoneIdentifier", Class.new(StandardError))
        end

        it "raises TZInfo::InvalidTimezoneIdentifier for invalid timezone" do
          timezone.timezone_id = "Invalid/Timezone"
          expect {
            timezone.tzinfo
          }.to raise_error(TZInfo::InvalidTimezoneIdentifier, /Invalid timezone/)
        end
      end
    end

    describe "real-world scenarios" do
      context "Toronto timezone" do
        it "represents Toronto correctly" do
          timezone.timezone_id = "America/Toronto"
          timezone.gmt_offset = -5.0
          timezone.dst_offset = -4.0

          expect(timezone.timezone_id).to eq("America/Toronto")
          expect(timezone.gmt_offset).to eq(-5.0)
          expect(timezone.dst_offset).to eq(-4.0)
        end
      end

      context "London timezone" do
        it "represents London correctly" do
          timezone.timezone_id = "Europe/London"
          timezone.gmt_offset = 0.0
          timezone.dst_offset = 1.0

          expect(timezone.timezone_id).to eq("Europe/London")
          expect(timezone.gmt_offset).to eq(0.0)
          expect(timezone.dst_offset).to eq(1.0)
        end
      end

      context "Tokyo timezone" do
        it "represents Tokyo correctly (no DST)" do
          timezone.timezone_id = "Asia/Tokyo"
          timezone.gmt_offset = 9.0
          timezone.dst_offset = 9.0

          expect(timezone.timezone_id).to eq("Asia/Tokyo")
          expect(timezone.gmt_offset).to eq(9.0)
          expect(timezone.dst_offset).to eq(9.0)
        end
      end

      context "UTC timezone" do
        it "represents UTC correctly" do
          timezone.timezone_id = "UTC"
          timezone.gmt_offset = 0.0
          timezone.dst_offset = 0.0

          expect(timezone.timezone_id).to eq("UTC")
          expect(timezone.gmt_offset).to eq(0.0)
          expect(timezone.dst_offset).to eq(0.0)
        end
      end

      context "partial hour offset" do
        it "handles timezones with 30-minute offsets" do
          timezone.timezone_id = "Asia/Kolkata"
          timezone.gmt_offset = 5.5
          timezone.dst_offset = 5.5

          expect(timezone.gmt_offset).to eq(5.5)
          expect(timezone.dst_offset).to eq(5.5)
        end

        it "handles timezones with 45-minute offsets" do
          timezone.timezone_id = "Pacific/Chatham"
          timezone.gmt_offset = 12.75
          timezone.dst_offset = 13.75

          expect(timezone.gmt_offset).to eq(12.75)
          expect(timezone.dst_offset).to eq(13.75)
        end
      end
    end

    describe "edge cases" do
      it "handles empty string timezone_id" do
        timezone.timezone_id = ""
        expect(timezone.timezone_id).to eq("")
      end

      it "handles very long timezone_id strings" do
        long_string = "A" * 1000
        timezone.timezone_id = long_string
        expect(timezone.timezone_id).to eq(long_string)
      end

      it "handles special characters in timezone_id" do
        special_strings = [
          "America/Argentina/Buenos_Aires",
          "America/Indiana/Indianapolis",
          "America/Kentucky/Louisville"
        ]

        special_strings.each do |tz|
          timezone.timezone_id = tz
          expect(timezone.timezone_id).to eq(tz)
        end
      end

      it "handles extreme offset values" do
        timezone.gmt_offset = -999.99
        expect(timezone.gmt_offset).to eq(-999.99)

        timezone.dst_offset = 999.99
        expect(timezone.dst_offset).to eq(999.99)
      end

      it "handles floating point precision" do
        offset = 5.123456789
        timezone.gmt_offset = offset
        expect(timezone.gmt_offset).to eq(offset)
      end
    end

    describe "data type flexibility" do
      it "accepts string numbers for offsets" do
        timezone.gmt_offset = "-5"
        expect(timezone.gmt_offset).to eq("-5")
      end

      it "stores whatever type is assigned" do
        timezone.timezone_id = 12345
        expect(timezone.timezone_id).to eq(12345)

        timezone.gmt_offset = "not a number"
        expect(timezone.gmt_offset).to eq("not a number")
      end
    end

    describe "multiple assignments" do
      it "allows reassigning values multiple times" do
        timezone.timezone_id = "America/Toronto"
        expect(timezone.timezone_id).to eq("America/Toronto")

        timezone.timezone_id = "America/New_York"
        expect(timezone.timezone_id).to eq("America/New_York")

        timezone.timezone_id = "Europe/London"
        expect(timezone.timezone_id).to eq("Europe/London")
      end

      it "maintains last assigned value" do
        10.times do |i|
          timezone.gmt_offset = i
        end
        expect(timezone.gmt_offset).to eq(9)
      end
    end
  end
end

