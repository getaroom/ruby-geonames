require 'spec_helper'

module Geonames
  describe WebService do
    describe ".country_info" do
      subject { country_info }
      let(:country_info) { WebService.country_info(country_code) }
      let(:response) { fixture_content(File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'country_info', fixture)) }

      context "with a country code of 'TH'" do
        before { WebMock.stub_request(:get, /\/countryInfo\?.*&country=#{country_code}/).to_return(body: response) }
        let(:fixture) { "thailand.xml.http" }
        let(:country_code) { "TH" }

        it { should be_a_kind_of(CountryInfo) }

        it "has the correct country_code" do
          expect(subject.country_code).to eq('TH')
        end
        it "has the correct country_name" do
          expect(subject.country_name).to eq('Thailand')
        end
        it "has the correct iso_numeric" do
          expect(subject.iso_numeric).to eq(764)
        end
        it "has the correct iso_alpha_3" do
          expect(subject.iso_alpha_3).to eq('THA')
        end
        it "has the correct fips_code" do
          expect(subject.fips_code).to eq('TH')
        end
        it "has the correct continent" do
          expect(subject.continent).to eq('AS')
        end
        it "has the correct capital" do
          expect(subject.capital).to eq('Bangkok')
        end
        it "has the correct area_sq_km" do
          expect(subject.area_sq_km).to eq(514000.0)
        end
        it "has the correct population" do
          expect(subject.population).to eq(67089500)
        end
        it "has the correct currency_code" do
          expect(subject.currency_code).to eq('THB')
        end
        it "has the correct geoname_id" do
          expect(subject.geoname_id).to eq(1605651)
        end
        it "has the correct languages" do
          expect(subject.languages).to eq(['th', 'en'])
        end

        describe "#bounding_box" do
          subject { country_info.bounding_box }

          it { should be_a_kind_of(BoundingBox) }
          it "has the correct north_point" do
            expect(subject.north_point).to eq(20.463194)
          end
          it "has the correct south_point" do
            expect(subject.south_point).to eq(5.61)
          end
          it "has the correct east_point" do
            expect(subject.east_point).to eq(105.639389)
          end
          it "has the correct west_point" do
            expect(subject.west_point).to eq(97.345642)
          end
        end
      end
    end
  end
end
