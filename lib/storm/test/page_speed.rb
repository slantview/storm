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

require 'storm/pagespeed'

module Storm
  class Test
    class PageSpeed < Test

      attr_reader :uri, :pagespeed, :apikey

      def initialize(uri = URI.new)
        @uri = uri
        @apikey = ENV['PAGESPEED_API_KEY'] || 'AIzaSyC6M3WtBHrB2B1PSpm0csE8Ca4N6itQXqo'
        @pagespeed = Storm::PageSpeed.new(@uri, @apikey)
      end

      def run(config={})
        @pagespeed.run
      end

      def report
        @pagespeed.result
      end
    end
  end
end
