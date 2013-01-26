#=============================================================================
#
# Copyright 2010 Jan Schwenzien <jan@schwenzien.info>
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
  class Config
    @@default_base_url = "http://api.geonames.org"
    @@default_lang     = "en"
    @@default_username = nil
    @@default_token    = nil

    attr_writer :base_url, :lang, :username, :token

    def base_url
      @base_url || @@default_base_url
    end

    def lang
      @lang || @@default_lang
    end

    def username
      @username || @@default_username
    end

    def token
      @token || @@default_token
    end
  end
end
