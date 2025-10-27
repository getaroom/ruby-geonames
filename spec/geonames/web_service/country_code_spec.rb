require 'spec_helper'

module Geonames
  describe WebService do
    describe ".country_code" do
      subject { WebService.country_code(latitude, longitude) }
      let(:response) { fixture_content(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'countrycode', fixture)) }

      before { WebMock.stub_request(:get, /\/countrycode\?.*lat=#{latitude}&lng=#{longitude}/).to_return(body: response) }
      let(:fixture) { "canada.xml.http" }

      let(:latitude)  { +43.900120387 }
      let(:longitude) { -78.882869834 }

      it { should be_a_kind_of(Array) }

      it "returns Toponym instances" do
        subject.each do |element|
          expect(element).to be_a_kind_of Toponym
        end
      end
    end
  end
end
