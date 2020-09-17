#=============================================================================
#
# Copyright 2007 Adam Wisniewski <adamw@tbcn.ca>
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

module Geonames
  autoload :BoundingBox,              'geonames/bounding_box'
  autoload :Config,                   'geonames/config'
  autoload :CountryInfo,              'geonames/country_info'
  autoload :CountrySubdivision,       'geonames/country_subdivision'
  autoload :Intersection,             'geonames/intersection'
  autoload :PostalCode,               'geonames/postal_code'
  autoload :PostalCodeSearchCriteria, 'geonames/postal_code_search_criteria'
  autoload :Timezone,                 'geonames/timezone'
  autoload :Toponym,                  'geonames/toponym'
  autoload :ToponymSearchCriteria,    'geonames/toponym_search_criteria'
  autoload :ToponymSearchResult,      'geonames/toponym_search_result'
  autoload :VERSION,                  'geonames/version'
  autoload :WebService,               'geonames/web_service'
  autoload :WikipediaArticle,         'geonames/wikipedia_article'

  GEONAMES_SERVER = "http://api.geonames.org"
  USER_AGENT      = "geonames ruby webservice client #{VERSION}"

  class << self
    def config
      Thread.current[:geonames_config] ||= Geonames::Config.new
    end

    %w(base_url lang username).each do |method|
      module_eval <<-DELEGATORS, __FILE__, __LINE__ + 1
        def #{method}
          config.#{method}
        end

        def #{method}=(value)
          config.#{method} = (value)
        end
      DELEGATORS
    end
  end
end
