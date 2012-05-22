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

require 'net/protocol'
require 'net/http'
require 'uri'

module Storm
  class HTTPRequest < Net::HTTP
    attr_reader :socket, :timer

    IDEMPOTENT_METHODS_ = %w/GET HEAD PUT DELETE OPTIONS TRACE/ # :nodoc:

    def initialize(address, port = nil)
      @timer = Hash.new
      %w{ connect send wait read close }.each do |state|
        @timer[state.to_sym] = Storm::Timer.new(state.to_sym)
      end
      super(address, port)
    end

    def timer
      @timer || Hash.new
    end

    def transport_request(req)
      count = 0
      begin
        @timer[:connect].start
        begin_transport req
        @timer[:connect].stop
        res = catch(:response) {
          # Test the sending of the HTTP Request
          @timer[:send].start
          req.exec @socket, @curr_http_version, edit_path(req.path)
          @timer[:send].stop

          # Test the time to wait until @socket is ready to recieve
          @timer[:wait].start
          ready = IO.select([@socket.io])
          @timer[:wait].stop

          # Test receiving the data
          begin
            @timer[:read].start
            res = Net::HTTPResponse.read_new(@socket)
          end while res.kind_of?(Net::HTTPContinue)
          res.reading_body(@socket, req.response_body_permitted?) {
            yield res if block_given?
          }
          @timer[:read].stop
          res
        }

      rescue Net::OpenTimeout
        raise
      rescue Net::ReadTimeout, IOError, EOFError,
             Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE,
             OpenSSL::SSL::SSLError, Timeout::Error => exception
        if count == 0 && IDEMPOTENT_METHODS_.include?(req.method)
          count += 1
          @socket.close if @socket and not @socket.closed?
          D "Conn close because of error #{exception}, and retry"
          retry
        end
        D "Conn close because of error #{exception}"
        @socket.close if @socket and not @socket.closed?
        raise
      end
      @timer[:close].start
      end_transport req, res
      @timer[:close].stop
      { :res => res, :timer => @timer }
    rescue => exception
      D "Conn close because of error #{exception}"
      @socket.close if @socket and not @socket.closed?
      raise exception
    end

  end
end
