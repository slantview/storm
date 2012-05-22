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
require 'dnsruby'
require 'benchmark'
require 'storm/test.rb'

module Storm
  class Test
    attr_reader :result

    def initialize
      @result = Array.new
    end

    def result
      @result ||= Array.new
    end

    def report
      report_data = Hash.new
      @result.each do |timer|
        report_data[timer.t_name] = timer.report(:ms)
      end
      report_data
    end
  end
end
