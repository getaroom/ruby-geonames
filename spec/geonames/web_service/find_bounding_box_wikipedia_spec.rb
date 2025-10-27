require 'spec_helper'

module Geonames
  describe WebService do
    describe ".find_bounding_box_wikipedia" do
      subject { WebService.find_bounding_box_wikipedia({ :north => north, :east => east, :south => south, :west => west }) }
      let(:response) { fixture_content(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'wikipedia_bounding_box', fixture)) }

      # TODO Why doesn't mocking the following regex work?
      # /\/wikipediaBoundingBox\?.*north=#{north}&east=#{east}&south=#{south}&west=#{west}/
      before { WebMock.stub_request(:get, /\/wikipediaBoundingBox\?/).to_return(body: response) }
      let(:fixture) { "wyoming.xml.http" }

      let(:north) { +43.900120387 }
      let(:east)  { -78.882869834 }
      let(:south) { +43.82 }
      let(:west)  { +79.0  }

      it { should be_a_kind_of(Array) }

      it "returns WikipediaArticle instances" do
        subject.each do |element|
          expect(element).to be_a_kind_of WikipediaArticle
        end
      end
    end
  end
end
