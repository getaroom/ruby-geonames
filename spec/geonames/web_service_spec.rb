require 'spec_helper'

module Geonames
  describe WebService do
    let(:latitude) { 43.900120387 }
    let(:longitude) { -78.882869834 }

    before do
      Geonames.username = 'test_user'
      Geonames.lang = 'en'
    end

    describe ".make_request" do
      let(:path) { '/test?a=a' }
      let(:full_url) { "#{Geonames.base_url}#{path}&username=test_user&lang=en" }

      context "with successful request" do
        before do
          stub_request(:get, full_url)
            .to_return(status: 200, body: '<geonames></geonames>')
        end

      it "uses a custom User-Agent header" do
          expect(Net::HTTP::Get).to receive(:new).with(anything, hash_including('User-Agent' => USER_AGENT)).and_call_original
          WebService.make_request(path)
        end

        it "includes username in the request" do
          WebService.make_request(path)
          expect(WebMock).to have_requested(:get, full_url)
        end

        it "includes language in the request" do
          WebService.make_request(path)
          expect(WebMock).to have_requested(:get, full_url)
        end

        it "returns a Net::HTTP response" do
          response = WebService.make_request(path)
          expect(response).to be_a(Net::HTTPResponse)
        end
      end

      context "with custom timeout options" do
        let(:custom_options) { { open_timeout: 30, read_timeout: 45 } }

        before do
          stub_request(:get, full_url)
            .to_return(status: 200, body: '<geonames></geonames>')
        end

        it "accepts custom timeout options" do
          http_mock = instance_double(Net::HTTP)
          allow(Net::HTTP).to receive(:start).and_yield(http_mock)
          allow(http_mock).to receive(:read_timeout=).with(45)
          allow(http_mock).to receive(:open_timeout=).with(30)
          allow(http_mock).to receive(:request).and_return(double(body: '<geonames></geonames>'))

          WebService.make_request(path, custom_options)
        end
      end

      context "when network timeout occurs" do
        before do
          stub_request(:get, full_url).to_timeout
        end

        it "raises a timeout error" do
          expect {
            WebService.make_request(path)
          }.to raise_error(Net::OpenTimeout)
        end
      end

      context "when server returns error status" do
        before do
          stub_request(:get, full_url)
            .to_return(status: 500, body: 'Internal Server Error')
        end

        it "returns response even with error status" do
          response = WebService.make_request(path)
          expect(response.code).to eq('500')
        end
      end

      context "when connection fails" do
        before do
          stub_request(:get, full_url).to_raise(SocketError.new('Failed to open TCP connection'))
        end

        it "raises a connection error" do
          expect {
            WebService.make_request(path)
          }.to raise_error(SocketError, /Failed to open TCP connection/)
        end
      end
    end

    describe ".timezone" do
      let(:timezone_url) { /\/timezone\?.*lat=#{latitude}&lng=#{longitude}/ }

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <timezone>
                <countryCode>CA</countryCode>
                <countryName>Canada</countryName>
                <lat>#{latitude}</lat>
                <lng>#{longitude}</lng>
                <timezoneId>America/Toronto</timezoneId>
                <dstOffset>-4.0</dstOffset>
                <gmtOffset>-5.0</gmtOffset>
              </timezone>
            </geonames>
          XML
        end

        before do
          stub_request(:get, timezone_url).to_return(body: response_body)
        end

        it "returns a Timezone object" do
          result = WebService.timezone(latitude, longitude)
          expect(result).to be_a(Timezone)
        end

        it "parses timezone_id correctly" do
          result = WebService.timezone(latitude, longitude)
          expect(result.timezone_id).to eq('America/Toronto')
        end

        it "parses gmt_offset correctly" do
          result = WebService.timezone(latitude, longitude)
          expect(result.gmt_offset).to eq(-5.0)
        end

        it "parses dst_offset correctly" do
          result = WebService.timezone(latitude, longitude)
          expect(result.dst_offset).to eq(-4.0)
        end
      end

      context "when API returns authorization error" do
        let(:error_response) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <status message="user account not enabled to use this service" value="10"/>
            </geonames>
          XML
        end

        before do
          stub_request(:get, timezone_url).to_return(body: error_response)
        end

        it "raises AuthorizationException" do
          expect {
            WebService.timezone(latitude, longitude)
          }.to raise_error(Geonames::Error::AuthorizationException, /user account not enabled/)
        end
      end

      context "when API returns no result found error" do
        let(:error_response) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <status message="no timezone found for coordinates" value="15"/>
            </geonames>
          XML
        end

        before do
          stub_request(:get, timezone_url).to_return(body: error_response)
        end

        it "raises NoResultFound error" do
          expect {
            WebService.timezone(latitude, longitude)
          }.to raise_error(Geonames::Error::NoResultFound, /no timezone found/)
        end
      end

      context "when API returns invalid parameter error" do
        let(:error_response) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <status message="invalid lat/lng" value="14"/>
            </geonames>
          XML
        end

        before do
          stub_request(:get, timezone_url).to_return(body: error_response)
        end

        it "raises InvalidParameter error" do
          expect {
            WebService.timezone(latitude, longitude)
          }.to raise_error(Geonames::Error::InvalidParameter, /invalid lat\/lng/)
        end
      end

      context "when API returns daily limit exceeded error" do
        let(:error_response) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <status message="daily limit of credits exceeded" value="18"/>
            </geonames>
          XML
        end

        before do
          stub_request(:get, timezone_url).to_return(body: error_response)
        end

        it "raises DailyLimitExceeded error" do
          expect {
            WebService.timezone(latitude, longitude)
          }.to raise_error(Geonames::Error::DailyLimitExceeded, /daily limit/)
        end
      end

      context "when API returns unknown error code" do
        let(:error_response) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <status message="unknown error occurred" value="999"/>
            </geonames>
          XML
        end

        before do
          stub_request(:get, timezone_url).to_return(body: error_response)
        end

        it "raises Unknown error" do
          expect {
            WebService.timezone(latitude, longitude)
          }.to raise_error(Geonames::Error::Unknown, /unknown error/)
        end
      end

      context "when response has malformed XML" do
        before do
          stub_request(:get, timezone_url).to_return(body: 'Not valid XML <>')
        end

        it "raises XML parsing error" do
          expect {
            WebService.timezone(latitude, longitude)
          }.to raise_error(REXML::ParseException)
        end
      end

      context "when response is empty" do
        before do
          stub_request(:get, timezone_url).to_return(body: '<geonames></geonames>')
        end

        it "returns empty Timezone object when no data present" do
          result = WebService.timezone(latitude, longitude)
          expect(result).to be_a(Timezone)
          expect(result.timezone_id).to be_nil
        end
      end
    end

    describe ".postal_code_search" do
      let(:search_criteria) { PostalCodeSearchCriteria.new }
      let(:postal_code_url) { /\/postalCodeSearch\?/ }

      before do
        search_criteria.place_name = 'Oshawa'
      end

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <code>
                <postalcode>L1G</postalcode>
                <name>Oshawa</name>
                <countryCode>CA</countryCode>
                <lat>43.9</lat>
                <lng>-78.85</lng>
                <adminCode1>ON</adminCode1>
                <adminName1>Ontario</adminName1>
                <adminCode2/>
                <adminName2/>
                <distance>0</distance>
              </code>
            </geonames>
          XML
        end

        before do
          stub_request(:get, postal_code_url).to_return(body: response_body)
        end

        it "returns an array of PostalCode objects" do
          result = WebService.postal_code_search(search_criteria)
          expect(result).to be_an(Array)
          expect(result.first).to be_a(PostalCode)
        end

        it "parses postal_code correctly" do
          result = WebService.postal_code_search(search_criteria)
          expect(result.first.postal_code).to eq('L1G')
        end

        it "parses place_name correctly" do
          result = WebService.postal_code_search(search_criteria)
          expect(result.first.place_name).to eq('Oshawa')
        end

        it "parses coordinates correctly" do
          result = WebService.postal_code_search(search_criteria)
          expect(result.first.latitude).to eq(43.9)
          expect(result.first.longitude).to eq(-78.85)
        end
      end

      context "when no results found" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
            </geonames>
          XML
        end

        before do
          stub_request(:get, postal_code_url).to_return(body: response_body)
        end

        it "returns an empty array" do
          result = WebService.postal_code_search(search_criteria)
          expect(result).to eq([])
        end
      end

      context "when request times out" do
        before do
          stub_request(:get, postal_code_url).to_timeout
        end

        it "raises timeout error" do
          expect {
            WebService.postal_code_search(search_criteria)
          }.to raise_error(Net::OpenTimeout)
        end
      end
    end

    describe ".find_nearby_postal_codes" do
      let(:search_criteria) { PostalCodeSearchCriteria.new }
      let(:nearby_url) { /\/findNearbyPostalCodes\?/ }

      before do
        search_criteria.latitude = latitude
        search_criteria.longitude = longitude
      end

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <code>
                <postalcode>L1H 7K4</postalcode>
                <name>Oshawa</name>
                <countryCode>CA</countryCode>
                <lat>43.9001</lat>
                <lng>-78.8828</lng>
                <adminCode1>ON</adminCode1>
                <adminName1>Ontario</adminName1>
                <distance>0.0</distance>
              </code>
            </geonames>
          XML
        end

        before do
          stub_request(:get, nearby_url).to_return(body: response_body)
        end

        it "returns an array of PostalCode objects" do
          result = WebService.find_nearby_postal_codes(search_criteria)
          expect(result).to be_an(Array)
          expect(result.first).to be_a(PostalCode)
        end

        it "includes distance in the results" do
          result = WebService.find_nearby_postal_codes(search_criteria)
          expect(result.first.distance).to eq(0.0)
        end
      end
    end

    describe ".find_nearby_place_name" do
      let(:place_url) { /\/findNearbyPlaceName\?.*lat=#{latitude}&lng=#{longitude}/ }

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <geoname>
                <name>Oshawa</name>
                <lat>43.900120387</lat>
                <lng>-78.882869834</lng>
                <geonameId>6094817</geonameId>
                <countryCode>CA</countryCode>
                <countryName>Canada</countryName>
                <fcl>P</fcl>
                <fcode>PPL</fcode>
                <distance>0</distance>
              </geoname>
            </geonames>
          XML
        end

        before do
          stub_request(:get, place_url).to_return(body: response_body)
        end

        it "returns an array of Toponym objects" do
          result = WebService.find_nearby_place_name(latitude, longitude)
          expect(result).to be_an(Array)
          expect(result.first).to be_a(Toponym)
        end

        it "parses toponym name correctly" do
          result = WebService.find_nearby_place_name(latitude, longitude)
          expect(result.first.name).to eq('Oshawa')
        end

        it "parses geoname_id correctly" do
          result = WebService.find_nearby_place_name(latitude, longitude)
          expect(result.first.geoname_id).to eq('6094817')
        end
      end

      context "when no places found" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
            </geonames>
          XML
        end

        before do
          stub_request(:get, place_url).to_return(body: response_body)
        end

        it "returns an empty array" do
          result = WebService.find_nearby_place_name(latitude, longitude)
          expect(result).to eq([])
        end
      end
    end

    describe ".find_nearest_intersection" do
      let(:intersection_url) { /\/findNearestIntersection\?.*lat=#{latitude}&lng=#{longitude}/ }

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <intersection>
                <street1>King Street</street1>
                <street2>Simcoe Street</street2>
                <lat>43.8971</lat>
                <lng>-78.8658</lng>
                <distance>0.02</distance>
                <postalcode>L1H 1A1</postalcode>
                <name>Oshawa</name>
                <countryCode>CA</countryCode>
              </intersection>
            </geonames>
          XML
        end

        before do
          stub_request(:get, intersection_url).to_return(body: response_body)
        end

        it "returns an Intersection object" do
          result = WebService.find_nearest_intersection(latitude, longitude)
          expect(result).to be_an(Intersection)
        end

        it "parses street names correctly" do
          result = WebService.find_nearest_intersection(latitude, longitude)
          expect(result.street_1).to eq('King Street')
          expect(result.street_2).to eq('Simcoe Street')
        end

        it "parses distance correctly" do
          result = WebService.find_nearest_intersection(latitude, longitude)
          expect(result.distance).to eq(0.02)
        end
      end

      context "when no intersection found" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
            </geonames>
          XML
        end

        before do
          stub_request(:get, intersection_url).to_return(body: response_body)
        end

        it "returns an empty array" do
          result = WebService.find_nearest_intersection(latitude, longitude)
          expect(result).to eq([])
        end
      end
    end

    describe ".find_nearby_wikipedia" do
      let(:wikipedia_url) { /\/findNearbyWikipedia\?/ }

      context "with lat/long parameters" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <entry>
                <lang>en</lang>
                <title>General Motors Centre</title>
                <summary>The General Motors Centre is an arena in downtown Oshawa...</summary>
                <feature>landmark</feature>
                <lat>43.8971</lat>
                <lng>-78.8658</lng>
                <wikipediaUrl>en.wikipedia.org/wiki/General_Motors_Centre</wikipediaUrl>
                <distance>1.5</distance>
              </entry>
            </geonames>
          XML
        end

        before do
          stub_request(:get, wikipedia_url).to_return(body: response_body)
        end

        it "returns an array of WikipediaArticle objects" do
          result = WebService.find_nearby_wikipedia(lat: latitude, long: longitude)
          expect(result).to be_an(Array)
          expect(result.first).to be_a(WikipediaArticle)
        end

        it "parses article details correctly" do
          result = WebService.find_nearby_wikipedia(lat: latitude, long: longitude)
          article = result.first
          expect(article.title).to eq('General Motors Centre')
          expect(article.language).to eq('en')
          expect(article.distance).to eq(1.5)
        end
      end

      context "with query parameter" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <entry>
                <lang>en</lang>
                <title>Toronto</title>
                <summary>Toronto is the capital of Ontario...</summary>
                <lat>43.70</lat>
                <lng>-79.42</lng>
              </entry>
            </geonames>
          XML
        end

        before do
          stub_request(:get, wikipedia_url).to_return(body: response_body)
        end

        it "accepts query parameter" do
          result = WebService.find_nearby_wikipedia(q: 'Toronto')
          expect(result.first.title).to eq('Toronto')
        end
      end

      context "when no articles found" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
            </geonames>
          XML
        end

        before do
          stub_request(:get, wikipedia_url).to_return(body: response_body)
        end

        it "returns an empty array" do
          result = WebService.find_nearby_wikipedia(lat: latitude, long: longitude)
          expect(result).to eq([])
        end
      end
    end

    describe ".find_bounding_box_wikipedia" do
      let(:bbox_url) { /\/wikipediaBoundingBox\?/ }
      let(:bbox_params) do
        {
          north: 44.1,
          south: 43.1,
          east: -78.0,
          west: -79.0
        }
      end

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <entry>
                <lang>en</lang>
                <title>Oshawa</title>
                <summary>Oshawa is a city in Ontario...</summary>
                <lat>43.897</lat>
                <lng>-78.866</lng>
              </entry>
            </geonames>
          XML
        end

        before do
          stub_request(:get, bbox_url).to_return(body: response_body)
        end

        it "returns an array of WikipediaArticle objects" do
          result = WebService.find_bounding_box_wikipedia(bbox_params)
          expect(result).to be_an(Array)
          expect(result.first).to be_a(WikipediaArticle)
        end

        it "includes max_rows parameter when provided" do
          WebService.find_bounding_box_wikipedia(bbox_params.merge(max_rows: 10))
          expect(WebMock).to have_requested(:get, /max_rows=10/)
        end
      end
    end

    describe ".country_subdivision" do
      let(:subdivision_url) { /\/countrySubdivision\?.*lat=#{latitude}&lng=#{longitude}/ }

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <countrySubdivision>
                <countryCode>CA</countryCode>
                <countryName>Canada</countryName>
                <adminCode1>ON</adminCode1>
                <adminName1>Ontario</adminName1>
                <code type="FIPS10-4">08</code>
                <code type="ISO3166-2">ON</code>
              </countrySubdivision>
            </geonames>
          XML
        end

        before do
          stub_request(:get, subdivision_url).to_return(body: response_body)
        end

        it "returns an array of CountrySubdivision objects" do
          result = WebService.country_subdivision(latitude, longitude)
          expect(result).to be_an(Array)
          expect(result.first).to be_a(CountrySubdivision)
        end

        it "parses subdivision details correctly" do
          result = WebService.country_subdivision(latitude, longitude)
          subdivision = result.first
          expect(subdivision.country_code).to eq('CA')
          expect(subdivision.admin_name_1).to eq('Ontario')
          expect(subdivision.code_iso).to eq('ON')
        end
      end

      context "with radius and maxRows parameters" do
        before do
          stub_request(:get, subdivision_url).to_return(
            body: '<geonames><countrySubdivision></countrySubdivision></geonames>'
          )
        end

        it "includes radius in request" do
          WebService.country_subdivision(latitude, longitude, 10, 5)
          expect(WebMock).to have_requested(:get, /radius=10/)
        end

        it "includes maxRows in request" do
          WebService.country_subdivision(latitude, longitude, 10, 5)
          expect(WebMock).to have_requested(:get, /maxRows=5/)
        end
      end
    end

    describe ".country_info" do
      let(:country_info_url) { /\/countryInfo\?/ }

      context "with country code" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <country>
                <countryCode>CA</countryCode>
                <countryName>Canada</countryName>
                <isoNumeric>124</isoNumeric>
                <isoAlpha3>CAN</isoAlpha3>
                <fipsCode>CA</fipsCode>
                <continent>NA</continent>
                <capital>Ottawa</capital>
                <areaInSqKm>9984670.0</areaInSqKm>
                <population>33679000</population>
                <currencyCode>CAD</currencyCode>
                <languages>en,fr</languages>
                <geonameId>6251999</geonameId>
                <bBoxNorth>83.110619</bBoxNorth>
                <bBoxSouth>41.67598</bBoxSouth>
                <bBoxEast>-52.636291</bBoxEast>
                <bBoxWest>-141.00275</bBoxWest>
              </country>
            </geonames>
          XML
        end

        before do
          stub_request(:get, country_info_url).to_return(body: response_body)
        end

        it "returns a CountryInfo object" do
          result = WebService.country_info('CA')
          expect(result).to be_a(CountryInfo)
        end

        it "parses all country details correctly" do
          result = WebService.country_info('CA')
          expect(result.country_code).to eq('CA')
          expect(result.country_name).to eq('Canada')
          expect(result.capital).to eq('Ottawa')
          expect(result.population).to eq(33679000)
          expect(result.languages).to eq(['en', 'fr'])
        end

        it "parses bounding box correctly" do
          result = WebService.country_info('CA')
          expect(result.bounding_box).to be_a(BoundingBox)
          expect(result.bounding_box.north_point).to eq(83.110619)
        end
      end

      context "without country code (all countries)" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <country>
                <countryCode>CA</countryCode>
                <countryName>Canada</countryName>
                <isoNumeric>124</isoNumeric>
                <languages>en,fr</languages>
              </country>
              <country>
                <countryCode>US</countryCode>
                <countryName>United States</countryName>
                <isoNumeric>840</isoNumeric>
                <languages>en</languages>
              </country>
            </geonames>
          XML
        end

        before do
          stub_request(:get, country_info_url).to_return(body: response_body)
        end

        it "returns an array of CountryInfo objects" do
          result = WebService.country_info
          expect(result).to be_an(Array)
          expect(result.length).to eq(2)
          expect(result.first).to be_a(CountryInfo)
        end
      end

      context "when API returns error" do
        before do
          stub_request(:get, country_info_url).to_return(status: 500, body: 'Internal Server Error')
        end

        it "raises error on malformed response" do
          expect {
            WebService.country_info('INVALID')
          }.to raise_error(REXML::ParseException)
        end
      end
    end

    describe ".country_code" do
      let(:country_code_url) { /\/countrycode\?.*lat=#{latitude}&lng=#{longitude}/ }

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <country>
                <countryCode>CA</countryCode>
                <countryName>Canada</countryName>
              </country>
            </geonames>
          XML
        end

        before do
          stub_request(:get, country_code_url).to_return(body: response_body)
        end

        it "returns an array of Toponym objects" do
          result = WebService.country_code(latitude, longitude)
          expect(result).to be_an(Array)
          expect(result.first).to be_a(Toponym)
        end

        it "includes country code" do
          result = WebService.country_code(latitude, longitude)
          expect(result.first.country_code).to eq('CA')
        end
      end

      context "with radius and maxRows" do
        before do
          stub_request(:get, country_code_url).to_return(
            body: '<geonames><country><countryCode>CA</countryCode></country></geonames>'
          )
        end

        it "includes parameters in request" do
          WebService.country_code(latitude, longitude, 20, 3)
          expect(WebMock).to have_requested(:get, /radius=20/)
          expect(WebMock).to have_requested(:get, /maxRows=3/)
        end
      end
    end

    describe ".search" do
      let(:search_criteria) { ToponymSearchCriteria.new }
      let(:search_url) { /\/search\?/ }

      before do
        search_criteria.q = 'Toronto'
      end

      context "with successful response" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <totalResultsCount>1</totalResultsCount>
              <geoname>
                <name>Toronto</name>
                <lat>43.70011</lat>
                <lng>-79.4163</lng>
                <geonameId>6167865</geonameId>
                <countryCode>CA</countryCode>
                <countryName>Canada</countryName>
                <fcl>P</fcl>
                <fcode>PPLA</fcode>
                <population>4612191</population>
              </geoname>
            </geonames>
          XML
        end

        before do
          stub_request(:get, search_url).to_return(body: response_body)
        end

        it "returns a ToponymSearchResult object" do
          result = WebService.search(search_criteria)
          expect(result).to be_a(ToponymSearchResult)
        end

        it "parses total results count" do
          result = WebService.search(search_criteria)
          expect(result.total_results_count).to eq('1')
        end

        it "parses toponyms" do
          result = WebService.search(search_criteria)
          expect(result.toponyms.length).to eq(1)
          expect(result.toponyms.first.name).to eq('Toronto')
          expect(result.toponyms.first.population).to eq(4612191)
        end
      end

      context "with multiple search parameters" do
        before do
          search_criteria.country_code = 'CA'
          search_criteria.feature_class = 'P'
          search_criteria.max_rows = '10'
          stub_request(:get, search_url).to_return(
            body: '<geonames><totalResultsCount>0</totalResultsCount></geonames>'
          )
        end

        it "includes all parameters in request" do
          WebService.search(search_criteria)
          expect(WebMock).to have_requested(:get, /q=Toronto/)
          expect(WebMock).to have_requested(:get, /country=CA/)
          expect(WebMock).to have_requested(:get, /featureClass=P/)
          expect(WebMock).to have_requested(:get, /maxRows=10/)
        end
      end

      context "when no results found" do
        let(:response_body) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <totalResultsCount>0</totalResultsCount>
            </geonames>
          XML
        end

        before do
          stub_request(:get, search_url).to_return(body: response_body)
        end

        it "returns empty search result" do
          result = WebService.search(search_criteria)
          expect(result.toponyms).to be_empty
          expect(result.total_results_count).to eq('0')
        end
      end
    end

    describe "element parsing methods" do
      describe ".get_element_child_text" do
        let(:xml) { '<parent><child>test value</child></parent>' }
        let(:element) { REXML::Document.new(xml).root }

        it "returns text content of child element" do
          result = WebService.get_element_child_text(element, 'child')
          expect(result).to eq('test value')
        end

        it "returns nil for missing child" do
          result = WebService.get_element_child_text(element, 'missing')
          expect(result).to be_nil
        end
      end

      describe ".get_element_child_float" do
        let(:xml) { '<parent><value>123.45</value></parent>' }
        let(:element) { REXML::Document.new(xml).root }

        it "returns float value of child element" do
          result = WebService.get_element_child_float(element, 'value')
          expect(result).to eq(123.45)
        end

        it "returns nil for missing child" do
          result = WebService.get_element_child_float(element, 'missing')
          expect(result).to be_nil
        end
      end

      describe ".get_element_child_int" do
        let(:xml) { '<parent><count>42</count></parent>' }
        let(:element) { REXML::Document.new(xml).root }

        it "returns integer value of child element" do
          result = WebService.get_element_child_int(element, 'count')
          expect(result).to eq(42)
        end

        it "returns nil for missing child" do
          result = WebService.get_element_child_int(element, 'missing')
          expect(result).to be_nil
        end
      end
    end

    describe ".create_error_from_status" do
      let(:xml_template) do
        ->(code, message) {
          <<~XML
            <?xml version="1.0" encoding="UTF-8" standalone="no"?>
            <geonames>
              <status message="#{message}" value="#{code}"/>
            </geonames>
          XML
        }
      end

      it "creates AuthorizationException for code 10" do
        doc = REXML::Document.new(xml_template.call(10, 'not authorized'))
        error = WebService.create_error_from_status(doc, latitude, longitude)
        expect(error).to be_a(Geonames::Error::AuthorizationException)
        expect(error.message).to include('not authorized')
      end

      it "creates DailyLimitExceeded for code 18" do
        doc = REXML::Document.new(xml_template.call(18, 'daily limit'))
        error = WebService.create_error_from_status(doc, latitude, longitude)
        expect(error).to be_a(Geonames::Error::DailyLimitExceeded)
      end

      it "creates HourlyLimitExceeded for code 19" do
        doc = REXML::Document.new(xml_template.call(19, 'hourly limit'))
        error = WebService.create_error_from_status(doc, latitude, longitude)
        expect(error).to be_a(Geonames::Error::HourlyLimitExceeded)
      end

      it "creates ServerOverloadedException for code 22" do
        doc = REXML::Document.new(xml_template.call(22, 'server overloaded'))
        error = WebService.create_error_from_status(doc, latitude, longitude)
        expect(error).to be_a(Geonames::Error::ServerOverloadedException)
      end

      it "includes lat/long in error message" do
        doc = REXML::Document.new(xml_template.call(10, 'test error'))
        error = WebService.create_error_from_status(doc, latitude, longitude)
        expect(error.message).to include("#{latitude}/#{longitude}")
      end
    end

    describe "backwards compatibility methods" do
      describe ".findNearbyWikipedia" do
        let(:wikipedia_url) { /\/findNearbyWikipedia\?/ }

        before do
          stub_request(:get, wikipedia_url).to_return(
            body: '<geonames></geonames>'
          )
        end

        it "delegates to find_nearby_wikipedia" do
          expect(WebService).to receive(:find_nearby_wikipedia).with({ lat: latitude, long: longitude })
          WebService.findNearbyWikipedia(lat: latitude, long: longitude)
        end
      end

      describe ".findBoundingBoxWikipedia" do
        let(:bbox_url) { /\/wikipediaBoundingBox\?/ }

        before do
          stub_request(:get, bbox_url).to_return(
            body: '<geonames></geonames>'
          )
        end

        it "delegates to find_bounding_box_wikipedia" do
          params = { north: 44, south: 43, east: -78, west: -79 }
          expect(WebService).to receive(:find_bounding_box_wikipedia).with(params)
          WebService.findBoundingBoxWikipedia(params)
        end
      end
    end
  end
end
