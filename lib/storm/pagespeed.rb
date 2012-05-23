#
# Author:: Steve Rude (<steve@slantview.com>)
# Copyright:: Copyright (c) 2012 Slantview Media.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Some code borrowed from 'blahed' at http://github.com/blahed/pagespeed
# Thanks!
#

require 'net/https'
require 'uri'
require 'json'

module Storm
  class PageSpeed

    PAGESPEED_API_URL = 'https://www.googleapis.com/pagespeedonline/v1/runPagespeed'

    attr_accessor :uri, :api_key, :result

    def initialize(uri, api_key)
      @uri, @api_key = uri, api_key
      @ps_uri = build_request_uri
      @result = Hash.new
    end

    def run
      http = Net::HTTP.new(@ps_uri.host, @ps_uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(@ps_uri.request_uri)
      response = http.request(request)

      if response.code.to_i == 200
        parse(response.body)
      else
        status_error(response)
      end

    rescue Exception => e
      Storm::Log.error "#{e.message}"
      Storm::Log.error e.backtrace.join("\n")
    end

    def status_error(response)
      error = JSON.parse(response.body)['error']
      Storm::Log.error "#{error['code']} - #{error['message']}"
    end

    private

    def build_request_uri
      uri = URI.parse(PAGESPEED_API_URL)
      uri.query = "url=#{@uri.to_s}&key=#{@api_key}"
      uri
    end

    def parse(res)
      res = JSON.parse(res)
      code = res['responseCode']
      @result[:TotalScore] = res['score']

      raise "PageSpeed Result Unavailable." unless code == 200

      res['formattedResults']['ruleResults'].each do |name, rule|
        @result[name] = rule['ruleScore']
      end
    end
  end
end
