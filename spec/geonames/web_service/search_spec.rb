require 'spec_helper'

module Geonames
  describe WebService do

    describe ".search Marchtrenk with full-style" do
      let(:query)  { "Marchtrenk" }
      
      before { FakeWeb.register_uri :get, /\/search\?.*q=#{query}/, :response => response }
      let(:fixture) { "marchtrenk.xml.http" }
      let(:response) { File.read File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'search', fixture) }

      subject { WebService.search(ToponymSearchCriteria.new(q: query, style: 'FULL')) }

      it "return full Toponym instance" do
        subject.toponyms.each do |element|
          element.should be_a_kind_of Toponym
        end
      end
    end
    
    describe ".search Upper Austria with full-style" do
      let(:query)  { "Upper Austria" }
      
      before { FakeWeb.register_uri :get, /\/search\?.*q=#{query.gsub(' ','.')}.*/, :response => response }
      let(:fixture) { "upper_austria.xml.http" }
      let(:response) { File.read File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'search', fixture) }

      subject { WebService.search(ToponymSearchCriteria.new(q: query, style: 'FULL', max_rows: "1")).toponyms.first }

      it "return full Toponym instance" do
        subject.should be_a_kind_of Toponym
        subject.alternate_names.count.should == 7
      end
    end
    
    describe ".search Austria with full-style" do
      let(:query)         { "Austria" }
      let(:country_code)  { "AT" }
      
      before { FakeWeb.register_uri :get, /\/search\?.*q=#{query}.*/, :response => response }
      let(:fixture) { "austria.xml.http" }
      let(:response) { File.read File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'search', fixture) }

      subject { WebService.search(ToponymSearchCriteria.new(q: query, country_code: country_code, style: 'FULL', max_rows: "1")).toponyms.first }

      it "return full Toponym instance" do
        subject.should be_a_kind_of Toponym
        subject.alternate_names.count.should == 105
        subject.timezone.should == "Europe/Vienna"
      end
    end
  end
end
