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

module Storm
  class Timer
    attr_accessor :t_name, :result

    def initialize(t_name = :default)
      @t_name = t_name
      @result = {
        :start => nil,
        :end => nil,
        :total => nil
      }
    end

    def start
      @result[:start] = Time.now
    end

    def stop
      @result[:end] = Time.now
      (@result[:total] = @result[:end] - @result[:start]).round(2)
    end

    def to_ms
      (@result[:total] * 1000).round(2)
    end

    def to_sec
      @result[:total].round(2)
    end

    def to_min
      (@result[:total] / 60).round(4)
    end

    def to_hour
      ((@result[:total] / 60) / 60).round(4)
    end

    def report(format = :ms)
      time = nil
      case format.to_sym
      when :ms
        time = to_ms
      when :sec
        time = to_sec
      when :min
        time = to_min
      else
        time = to_ms
      end
      "#{time}#{format.to_s}"
    end
  end
end
