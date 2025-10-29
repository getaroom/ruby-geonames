require 'spec_helper'

module Geonames
  describe WebService do
    describe ".timezone" do
      subject { WebService.timezone(latitude, longitude) }
      let(:response) { File.read(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'timezone', fixture)) }

      before { WebMock.stub_request(:get, /\/timezone\?.*lat=#{latitude}&lng=#{longitude}/).to_return(body: response) }
      let(:fixture) { "america_toronto.xml.http" }

      let(:latitude)  { +43.900120387 }
      let(:longitude) { -78.882869834 }

      it { should be_a_kind_of(Timezone) }
    end
  end
end
