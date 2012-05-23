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

require 'net/dns'
require 'net/dns/resolver'

module Storm
  class Test
    class DNS < Test

      DNS_TEST_SERVER = "8.8.8.8" || ENV['DNS_TEST_SERVER']

      attr_reader :host

      def initialize(*args)
        @host = args[0]
        @timer = Storm::Timer.new(:Lookup)
        @result = Array.new
      end

      def run(config={})
        res = Net::DNS::Resolver.new(:nameservers => Storm::Test::DNS::DNS_TEST_SERVER)
        @timer.start
        ret = res.query(@host)
        @timer.stop

        @result << @timer
      end
    end
  end
end
