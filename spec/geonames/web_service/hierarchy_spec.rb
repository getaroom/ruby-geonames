require 'spec_helper'

module Geonames
  describe WebService do
    describe ".hierarchy" do
      subject { WebService.hierarchy(geonameId) }
      let(:response) { File.read File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'hierarchy', fixture) }

      before { FakeWeb.register_uri :get, /\/hierarchy\?geonameId=#{geonameId}/, :response => response }
      let(:fixture) { "zurich.xml.http" }

      let(:geonameId)  { 2657896 }

      it { should be_a_kind_of(Array) }

      it "returns Toponym instances" do
        subject.each do |element|
          element.should be_a_kind_of Toponym
        end
      end
    end
  end
end
