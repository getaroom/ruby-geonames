#=============================================================================
#
# Copyright 2007 Adam Wisniewski <adamw@tbcn.ca>
# Contributions by Andrew Turner, High Earth Orbit
# Contributions by Chris Griego
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#
#=============================================================================

require 'cgi'
require 'geonames'
require 'net/http'
require 'rexml/document'

module Geonames
  module WebService
    module_function

    def get_element_child_text(element, child)
      element.elements[child][0].to_s unless element.elements[child].nil?
    end

    def get_element_child_float(element, child)
      element.elements[child][0].to_s.to_f unless element.elements[child].nil?
    end

    def get_element_child_int(element, child)
      element.elements[child][0].to_s.to_i unless element.elements[child].nil?
    end

    def element_to_postal_code(element)
      postal_code = PostalCode.new

      postal_code.admin_code_1 = get_element_child_text(element,  'adminCode1')
      postal_code.admin_code_2 = get_element_child_text(element,  'adminCode2')
      postal_code.admin_name_1 = get_element_child_text(element,  'adminName1')
      postal_code.admin_name_2 = get_element_child_text(element,  'adminName2')
      postal_code.country_code = get_element_child_text(element,  'countryCode')
      postal_code.distance     = get_element_child_float(element, 'distance')
      postal_code.longitude    = get_element_child_float(element, 'lng')
      postal_code.latitude     = get_element_child_float(element, 'lat')
      postal_code.place_name   = get_element_child_text(element,  'name')
      postal_code.postal_code  = get_element_child_text(element,  'postalcode')

      postal_code
    end

    def element_to_wikipedia_article(element)
      article = WikipediaArticle.new

      article.language      = get_element_child_text(element,  'lang')
      article.title         = get_element_child_text(element,  'title')
      article.summary       = get_element_child_text(element,  'summary')
      article.wikipedia_url = get_element_child_text(element,  'wikipediaUrl')
      article.feature       = get_element_child_text(element,  'feature')
      article.population    = get_element_child_text(element,  'population')
      article.elevation     = get_element_child_text(element,  'elevation')
      article.latitude      = get_element_child_float(element, 'lat')
      article.longitude     = get_element_child_float(element, 'lng')
      article.thumbnail_img = get_element_child_text(element,  'thumbnailImg')
      article.distance      = get_element_child_float(element, 'distance')

      article
    end

    def element_to_toponym(element)
      toponym = Toponym.new

      toponym.name               = get_element_child_text(element,  'name')
      toponym.alternate_names    = get_element_child_text(element,  'alternateNames')
      toponym.latitude           = get_element_child_float(element, 'lat')
      toponym.longitude          = get_element_child_float(element, 'lng')
      toponym.geoname_id         = get_element_child_text(element,  'geonameId')
      toponym.country_code       = get_element_child_text(element,  'countryCode')
      toponym.country_name       = get_element_child_text(element,  'countryName')
      toponym.feature_class      = get_element_child_text(element,  'fcl')
      toponym.feature_code       = get_element_child_text(element,  'fcode')
      toponym.feature_class_name = get_element_child_text(element,  'fclName')
      toponym.feature_code_name  = get_element_child_text(element,  'fcodeName')
      toponym.population         = get_element_child_int(element,   'population')
      toponym.elevation          = get_element_child_text(element,  'elevation')
      toponym.distance           = get_element_child_float(element, 'distance')
      toponym.admin_code_1       = get_element_child_text(element,  'adminCode1')
      toponym.admin_code_2       = get_element_child_text(element,  'adminCode2')
      toponym.admin_name_1       = get_element_child_text(element,  'adminName1')
      toponym.admin_name_2       = get_element_child_text(element,  'adminName2')

      toponym
    end

    def element_to_intersection(element)
      intersection = Intersection.new

      intersection.street_1     = get_element_child_text(element,  'street1')
      intersection.street_2     = get_element_child_text(element,  'street2')
      intersection.admin_code_1 = get_element_child_text(element,  'adminCode1')
      intersection.admin_code_1 = get_element_child_text(element,  'adminCode1')
      intersection.admin_code_2 = get_element_child_text(element,  'adminCode2')
      intersection.admin_name_1 = get_element_child_text(element,  'adminName1')
      intersection.admin_name_2 = get_element_child_text(element,  'adminName2')
      intersection.country_code = get_element_child_text(element,  'countryCode')
      intersection.distance     = get_element_child_float(element, 'distance')
      intersection.longitude    = get_element_child_float(element, 'lat')
      intersection.latitude     = get_element_child_float(element, 'lng')
      intersection.place_name   = get_element_child_text(element,  'name')
      intersection.postal_code  = get_element_child_text(element,  'postalcode')

      intersection
    end

    def element_to_country_info(element)
      country_info = Geonames::CountryInfo.new

      country_info.country_code  = get_element_child_text(element,  'countryCode')
      country_info.country_name  = get_element_child_text(element,  'countryName')
      country_info.iso_numeric   = get_element_child_int(element,   'isoNumeric')
      country_info.iso_alpha_3   = get_element_child_text(element,  'isoAlpha3')
      country_info.fips_code     = get_element_child_text(element,  'fipsCode')
      country_info.continent     = get_element_child_text(element,  'continent')
      country_info.capital       = get_element_child_text(element,  'capital')
      country_info.area_sq_km    = get_element_child_float(element, 'areaInSqKm')
      country_info.population    = get_element_child_int(element,   'population')
      country_info.currency_code = get_element_child_text(element,  'currencyCode')
      country_info.languages     = get_element_child_text(element,  'languages').split(",")
      country_info.geoname_id    = get_element_child_int(element,   'geonameId')

      north = get_element_child_float(element, 'bBoxNorth')
      south = get_element_child_float(element, 'bBoxSouth')
      east  = get_element_child_float(element, 'bBoxEast')
      west  = get_element_child_float(element, 'bBoxWest')

      country_info.set_bounding_box(north, south, east, west)

      country_info
    end

    def postal_code_search(search_criteria, *args)
      # postal codes to reutrn
      postal_codes = []

      url = "/postalCodeSearch?a=a"
      url << search_criteria.to_query_params_string

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      doc.elements.each("geonames/code") do |element|
        postal_codes << element_to_postal_code(element)
      end

      postal_codes
    end

    def find_nearby_postal_codes(search_criteria, *args)
      # postal codes to reutrn
      postal_codes = []

      url = "/findNearbyPostalCodes?a=a"
      url << search_criteria.to_query_params_string

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      doc.elements.each("geonames/code") do |element|
        postal_codes << element_to_postal_code(element)
      end

      postal_codes
    end

    def find_nearby_place_name(lat, long, *args)
      places = []

      url = "/findNearbyPlaceName?a=a"

      url << "&lat=" + lat.to_s
      url << "&lng=" + long.to_s

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      doc.elements.each("geonames/geoname") do |element|
        places << element_to_toponym(element)
      end

      places
    end

    def find_nearest_intersection(lat, long, *args)
      url = "/findNearestIntersection?a=a"

      url << "&lat=" + lat.to_s
      url << "&lng=" + long.to_s

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      intersection = []

      doc.elements.each("geonames/intersection") do |element|
        intersection = element_to_intersection(element)
      end

      intersection
    end

    def timezone(lat, long, *args)
      res = make_request("/timezone?lat=#{lat.to_s}&lng=#{long.to_s}", args)
      doc = REXML::Document.new res.body
      timezone = Timezone.new

      raise create_error_from_status(doc, lat, long) if doc.elements["geonames/timezone"].nil? && !doc.elements["geonames/status"].nil?

      doc.elements.each("geonames/timezone") do |element|
        timezone.timezone_id = get_element_child_text(element,  'timezoneId')
        timezone.gmt_offset  = get_element_child_float(element, 'gmtOffset')
        timezone.dst_offset  = get_element_child_float(element, 'dstOffset')
      end

      timezone
    end

    def create_error_from_status(doc, lat, long)
      error_code = doc.elements["geonames/status"].attributes["value"].to_i
      error_message = doc.elements["geonames/status"].attributes["message"]
      Geonames::Error.from_code(error_code, "#{error_message} for lat/long #{lat}/#{long}")
    end

    def make_request(path_and_query, *args)
      url = Geonames.base_url + path_and_query
      url += "&username=#{Geonames.username}" if Geonames.username
      url += "&lang=#{Geonames.lang}"

      options = { :open_timeout => 60, :read_timeout => 60 }
      options.update(args.last.is_a?(Hash) ? args.pop : {})

      uri = URI.parse(url)
      req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}", 'User-Agent' => USER_AGENT)

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.read_timeout = options[:read_timeout]
        http.open_timeout = options[:open_timeout]
        http.request(req)
      end
    end

    def findNearbyWikipedia(hashes)
      # here for backwards compatibility
      find_nearby_wikipedia(hashes)
    end

    def find_nearby_wikipedia(hashes, *args)
      articles = []

      lat        = hashes[:lat]
      long       = hashes[:long]
      lang       = hashes[:lang]
      radius     = hashes[:radius]
      max_rows   = hashes[:max_rows]
      country    = hashes[:country]
      postalcode = hashes[:postalcode]
      q          = hashes[:q]

      url = "/findNearbyWikipedia?a=a"

      if !lat.nil? && !long.nil?
        url << "&lat="      + lat.to_s
        url << "&lng="      + long.to_s
        url << "&radius="   + radius.to_s   unless radius.nil?
        url << "&max_rows=" + max_rows.to_s unless max_rows.nil?
      elsif !q.nil?
        url << "&q="        + q
        url << "&radius="   + radius.to_s   unless radius.nil?
        url << "&max_rows=" + max_rows.to_s unless max_rows.nil?
      end

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      doc.elements.each("geonames/entry") do |element|
        articles << element_to_wikipedia_article(element)
      end

      articles
    end

    def findBoundingBoxWikipedia(hashes)
      # here for backwards compatibility
      find_bounding_box_wikipedia(hashes)
    end

    def find_bounding_box_wikipedia(hashes, *args)
      articles = []

      north      = hashes[:north]
      east       = hashes[:east]
      south      = hashes[:south]
      west       = hashes[:west]
      lang       = hashes[:lang]
      radius     = hashes[:radius]
      max_rows   = hashes[:max_rows]
      country    = hashes[:country]
      postalcode = hashes[:postalcode]
      q          = hashes[:q]

      url = "/wikipediaBoundingBox?a=a"

      url << "&north="    + north.to_s
      url << "&east="     + east.to_s
      url << "&south="    + south.to_s
      url << "&west="     + west.to_s
      url << "&radius="   + radius.to_s   unless radius.nil?
      url << "&max_rows=" + max_rows.to_s unless max_rows.nil?

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      doc.elements.each("geonames/entry") do |element|
        articles << element_to_wikipedia_article(element)
      end

      articles
    end

    def country_subdivision(lat, long, radius=0, maxRows=1, *args)
      country_subdivisions = []

      # maxRows is only implemented in the xml version:
      # http://groups.google.com/group/geonames/browse_thread/thread/f7f1bb2504ed216e
      # Therefore 'type=xml' is added:
      url = "/countrySubdivision?a=a&type=xml"

      url << "&lat="     + lat.to_s
      url << "&lng="     + long.to_s
      url << "&maxRows=" + maxRows.to_s
      url << "&radius="  + radius.to_s

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      doc.elements.each("geonames/countrySubdivision") do |element|
        country_subdivision = CountrySubdivision.new

        country_subdivision.country_code = get_element_child_text(element, 'countryCode')
        country_subdivision.country_name = get_element_child_text(element, 'countryName')
        country_subdivision.admin_code_1 = get_element_child_text(element, 'adminCode1')
        country_subdivision.admin_name_1 = get_element_child_text(element, 'adminName1')
        country_subdivision.code_fips    = get_element_child_text(element, 'code[@type="FIPS10-4"]')
        country_subdivision.code_iso     = get_element_child_text(element, 'code[@type="ISO3166-2"]')

        country_subdivisions << country_subdivision
      end

      country_subdivisions
    end

    def country_info(country_code=nil, *args)
      url = "/countryInfo?a=a"
      url += "&country=#{country_code.to_s}" unless country_code.nil?
      res = make_request(url, args)

      doc = REXML::Document.new res.body

      countries = []

      doc.elements.each("geonames/country") do |element|
        countries << element_to_country_info(element)
      end

      countries.size > 1 ? countries : countries[0]
    end

    def country_code(lat, long, radius=0, maxRows=1, *args)
      # maxRows is only implemented in the xml version:
      # http://groups.google.com/group/geonames/browse_thread/thread/f7f1bb2504ed216e
      # Therefore 'type=xml' is added:
      url = "/countrycode?a=a&type=xml"

      countries = []

      url << "&lat="     + lat.to_s
      url << "&lng="     + long.to_s
      url << "&maxRows=" + maxRows.to_s
      url << "&radius="  + radius.to_s

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      doc.elements.each("geonames/country") do |element|
        countries << element_to_toponym(element)
      end

      countries
    end

    def search(search_criteria, *args)
      #toponym search results to return
      toponym_sr = ToponymSearchResult.new

      url = "/search?a=a"
      url << "&q="               + CGI.escape(search_criteria.q)                unless search_criteria.q.nil?
      url << "&name_equals="     + CGI.escape(search_criteria.name_equals)      unless search_criteria.name_equals.nil?
      url << "&name_startsWith=" + CGI.escape(search_criteria.name_starts_with) unless search_criteria.name_starts_with.nil?
      url << "&name="            + CGI.escape(search_criteria.name)             unless search_criteria.name.nil?
      url << "&tag="             + CGI.escape(search_criteria.tag)              unless search_criteria.tag.nil?
      url << "&country="         + CGI.escape(search_criteria.country_code)     unless search_criteria.country_code.nil?
      url << "&adminCode1="      + CGI.escape(search_criteria.admin_code_1)     unless search_criteria.admin_code_1.nil?
      url << "&lang="            + CGI.escape(search_criteria.language)         unless search_criteria.language.nil?
      url << "&featureClass="    + CGI.escape(search_criteria.feature_class)    unless search_criteria.feature_class.nil?
      url << "&maxRows="         + CGI.escape(search_criteria.max_rows)         unless search_criteria.max_rows.nil?
      url << "&startRow="        + CGI.escape(search_criteria.start_row)        unless search_criteria.start_row.nil?
      url << "&style="           + CGI.escape(search_criteria.style)            unless search_criteria.style.nil?
      url << search_criteria.feature_codes.map {|fcode| "&fcode=" + CGI.escape(fcode) }.join unless search_criteria.feature_codes.nil?

      res = make_request(url, args)

      doc = REXML::Document.new res.body

      toponym_sr.total_results_count = doc.elements["geonames/totalResultsCount"].text

      doc.elements.each("geonames/geoname") do |element|
        toponym_sr.toponyms << element_to_toponym(element)
      end

      toponym_sr
    end
  end
end
