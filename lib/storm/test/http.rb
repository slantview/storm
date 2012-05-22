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

require 'rubygems'
require 'storm/test.rb'
require 'storm/http_request'

module Storm
  class Test
    class HTTP < Test

      attr_reader :uri, :method, :headers, :params, :req, :res

      def initialize(uri = URI.new, method = :get, headers = nil, params = nil)
        @uri, @method, @headers, @params = uri, method, headers, params
        @uri = URI(uri) if uri.is_a? String
        @result = Array.new
      end

      def run(config={})
        case @method.to_sym
        when :get
          @uri.query = URI.encode_www_form(@params) unless @params.nil?
          @req = Storm::HTTPRequest::Get.new(@uri.request_uri)
        when :post
          @req = Storm::HTTPRequest::Post.new(@uri.path)
          @req.set_form_data(@params) unless @params.nil?
        end

        add_headers(config)

        begin
          result = Storm::HTTPRequest.start(@uri.hostname, @uri.port) do |http|
            http.request(@req)
          end
          @res = result[:res]
          @timer = result[:timer]
          @timer.each do |n,t|
            @result << t
          end
        rescue Exception => e
          puts "ERROR: #{e}"
        end
      end
    end

    def add_headers(config={})
      case config[:ua]

      # OSX Browsers
      when :osxsafari
        @req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10'
      when :osxchrome
        @req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.46 Safari/536.5'
      when :osxff
        @req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:12.0) Gecko/20100101 Firefox/12.0'

      # Windows Browsers
      when :winie
        @req['User-Agent'] = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; storm/#{Storm::VERSION})"
      when :winchrome
        @req['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.6 (KHTML, like Gecko) Chrome/20.0.1092.0 Safari/536.6'
      when :winff
        @req['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1; rv:12.0) Gecko/20120403211507 Firefox/12.0'

      # Mobile Browsers
      when :iphone
        @req['User-Agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3'
      when :ipad
        @req['User-Agent'] = 'Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko ) Version/5.1 Mobile/9B176 Safari/7534.48.3'
      when :androidwebkit
        @req['User-Agent'] = 'Mozilla/5.0 (Linux; U; Android 2.3; en-us) AppleWebKit/999+ (KHTML, like Gecko) Safari/999.9'
      when :androidopera
        @req['User-Agent'] = 'Opera/9.80 (Android 2.3.4; Linux; Opera Mobi/build-1107180945; U; en-us) Presto/2.8.149 Version/11.10'
      when :blackberry
        @req['User-Agent'] = 'Mozilla/5.0 (BlackBerry; U; BlackBerry 9900; en) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.1.0.346 Mobile Safari/534.11+'
      end

      if config[:close]
        @req['Connection'] = 'close'
      end

      if not config[:cache]
        @req['Cookie'] = 'NO_CACHE=1; SESS3f01150bb9dfa96498cc502848b9949a=3f01150bb9dfa96498cc502848b9949a'
        @req['Cache-Control'] = 'no-cache no-store max-age=0'
      end
    end
  end
end
