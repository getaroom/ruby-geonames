require 'spec_helper'

module Geonames
  describe WebService do
    describe ".postal_code_search" do
      subject { WebService.postal_code_search(criteria) }
      let(:response) { fixture_content(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'postal_code_search', fixture)) }

      context "lookup by place name" do
        before { WebMock.stub_request(:get, /\/postalCodeSearch\?.*&placename=Oshawa/).to_return(body: response) }
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

      context "lookup by latitude and longitude" do
        before { WebMock.stub_request(:get, /\/postalCodeSearch\?.*&lat=47.*&lng=9/).to_return(body: response) }
        let(:fixture) { "lat_lng.xml.http" }

        let :criteria do
          Geonames::PostalCodeSearchCriteria.new.tap do |criteria|
            criteria.latitude  = 47
            criteria.longitude = 9
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
