require 'spec_helper'

module Geonames
  describe WebService do
    describe ".find_nearest_intersection" do
      subject { WebService.find_nearest_intersection(latitude, longitude) }
      let(:response) { fixture_content(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'find_nearest_intersection', fixture)) }

      before { WebMock.stub_request(:get, /\/findNearestIntersection\?.*lat=#{latitude}&lng=#{longitude}/).to_return(body: response) }
      let(:fixture) { "park_ave_and_e_51st_st.xml.http" }

      let(:latitude)  { +43.900120387 }
      let(:longitude) { -78.882869834 }

      it { should be_a_kind_of(Intersection) }
    end
  end
end
