require 'spec_helper'

module Geonames
  describe WebService do
    describe ".find_nearby_wikipedia" do
      subject { WebService.find_nearby_wikipedia({ :lat => latitude, :long => longitude }) }
      let(:response) { File.read(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'find_nearby_wikipedia', fixture)) }

      before { WebMock.stub_request(:get, /\/findNearbyWikipedia\?.*lat=#{latitude}&lng=#{longitude}/).to_return(body: response) }
      let(:fixture) { "general_motors_centre.xml.http" }

      let(:latitude)  { +43.900120387 }
      let(:longitude) { -78.882869834 }

      context "lookup by latitude and longitude" do
        it { should be_a_kind_of(Array) }

        it "returns WikipediaArticle instances" do
          subject.each do |element|
            expect(element).to be_a_kind_of WikipediaArticle
          end
        end
      end
    end
  end
end
