require 'spec_helper'

module Geonames
  describe WebService do
    describe ".find_nearby_postal_codes" do
      subject { WebService.find_nearby_postal_codes(criteria) }
      let(:response) { fixture_content(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'find_nearby_postal_codes', fixture)) }

      context "lookup by place name" do
        before { WebMock.stub_request(:get, /\/findNearbyPostalCodes\?.*&placename=Oshawa/).to_return(body: response) }
        let(:fixture) { "oshawa.xml.http" }

        let :criteria do
          Geonames::PostalCodeSearchCriteria.new.tap do |criteria|
            criteria.place_name = "Oshawa"
          end
        end

        it { should be_a_kind_of(Array) }

        it "returns PostalCode instances" do
          subject.each do |element|
            expect(element).to be_a_kind_of PostalCode
          end
        end
      end
    end
  end
end
