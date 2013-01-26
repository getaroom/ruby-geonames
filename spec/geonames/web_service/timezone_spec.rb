require 'spec_helper'

module Geonames
  describe WebService do
    describe ".timezone" do
      subject { WebService.timezone(latitude, longitude) }
      let(:response) { File.read File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'timezone', fixture) }

      before { FakeWeb.register_uri :get, /\/timezone\?.*lat=#{latitude}&lng=#{longitude}/, :response => response }
      let(:fixture) { "america_toronto.xml.http" }

      let(:latitude)  { +43.900120387 }
      let(:longitude) { -78.882869834 }

      it { should be_a_kind_of(Timezone) }

      it "should have the raw offset set" do
        subject.raw_offset.should == -5.0
      end
    end
  end
end
