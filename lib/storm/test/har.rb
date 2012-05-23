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

require 'har'
require 'time'
require 'date'

module HAR
  class Archive
    attr_reader :data
  end
end

module Storm
  class Test
    class HAR < Test

      PHANTOMJS = "phantomjs" || ENV['DNS_TEST_SERVER']
      NETSNIFF = STORM_ROOT + "/etc/netsniff.js"

      attr_reader :uri, :har, :result, :raw, :config

      def initialize(config={})
        @uri, @config = config[:uri], config
        @result = Array.new
        @raw = String.new
      end

      def run(config={})
        @raw = IO.popen("#{PHANTOMJS} #{NETSNIFF} #{@uri.to_s}").read
        @har = ::HAR::Archive.from_string(@raw)
      end

      def report
        if @config[:format] == :text
          @har.entries.each do |entry|
            t = Storm::Timer.new
            # Remove cruft.
            if entry.request.url =~ /^http/
              t.t_name = entry.request.url.gsub(/(\?.*)$/, '')
            elsif entry.request.url =~ /^data/
              t.t_name = "(base64 encoded data)"
            end
            t.result[:start] = entry.started_date_time.to_time
            t.result[:end] = t.result[:start] + (entry.time.to_f / 1000).to_f
            t.result[:total] = t.result[:end] - t.result[:start]
            @result << t
          end
          report_data = Hash.new
            @result.each do |timer|
              report_data[timer.t_name] = timer.report(:ms)
            end
          report_data
        elsif @config[:format] == :json
          @har.data
        end
      end
    end
  end
end
