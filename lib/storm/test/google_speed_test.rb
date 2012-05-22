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
    class GoogleSpeedTest < Test

      attr_reader :uri, :method, :headers, :params, :req, :res

      def initialize(uri = URI.new, method = :get, headers = nil, params = nil)
        @uri, @method, @headers, @params = uri, method, headers, params
        @uri = URI(uri) if uri.is_a? String
        @result = Array.new
      end

      def run
        case @method.to_sym
        when :get
          @uri.query = URI.encode_www_form(@params) unless @params.nil?
          @req = Storm::HTTPRequest::Get.new(@uri.request_uri)
        when :post
          @req = Storm::HTTPRequest::Post.new(@uri.path)
          @req.set_form_data(@params) unless @params.nil?
        end

        add_headers

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

    def add_headers
      @req['Connection'] = 'close'
      @req['Cookie'] = 'NO_CACHE=1'
    end
  end
end
