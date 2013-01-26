require 'spec_helper'

module Geonames
  describe WebService do
    describe ".find_nearby" do
      subject { WebService.find_nearby(latitude, longitude) }
      let(:response) { File.read File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'find_nearby', fixture) }

      before { FakeWeb.register_uri :get, /\/findNearby\?.*lat=#{latitude}&lng=#{longitude}/, :response => response }
      let(:fixture) { "wilkinson.xml.http" }

      let(:latitude)  { +37.501707 }
      let(:longitude) { -122.468838 }

      it { should be_a_kind_of(Array) }

      it "returns Toponym instances" do
        subject.each do |element|
          element.should be_a_kind_of Toponym
        end
      end
    end

    describe ".find_nearby with full-style" do
      let(:latitude)  { 48.18 }
      let(:longitude) { 14.11 }
      
      before { FakeWeb.register_uri :get, /\/findNearby\?.*lat=#{latitude}&lng=#{longitude}/, :response => response }
      let(:fixture) { "marchtrenk.xml.http" }
      let(:response) { File.read File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'find_nearby', fixture) }

      subject { WebService.find_nearby(latitude, longitude, style: 'FULL') }

      it "return full Toponym instance" do
        subject.each do |element|
          element.should be_a_kind_of Toponym
        end
      end
    end
  end
end
