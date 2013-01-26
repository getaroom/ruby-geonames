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

require 'cgi'

module Geonames
  class PostalCodeSearchCriteria
    attr_accessor :postal_code, :place_name, :country_code,
                  :latitude, :longitude, :style,
                  :max_rows,  :is_or_operator, :radius
    
    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end if params

      @is_or_operator = false
    end

    def to_query_params_string
      url = ''
      url << "&postalcode=" + CGI.escape(@postal_code)    unless @postal_code.nil?
      url << "&placename="  + CGI.escape(@place_name)     unless @place_name.nil?
      url << "&lat="        + CGI.escape(@latitude.to_s)  unless @latitude.nil?
      url << "&lng="        + CGI.escape(@longitude.to_s) unless @longitude.nil?
      url << "&style="      + CGI.escape(@style)          unless @style.nil?
      url << "&country="    + CGI.escape(@country_code)   unless @country_code.nil?
      url << "&maxRows="    + CGI.escape(@max_rows.to_s)  unless @max_rows.nil?
      url << "&radius="     + CGI.escape(@radius.to_s)    unless @radius.nil?
      url << "&operator=OR" if @is_or_operator
      url
    end
  end
end
