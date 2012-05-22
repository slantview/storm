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

require 'storm'
require 'uri'
require 'mixlib/cli'
require 'storm/test/dns'
require 'storm/test/http'
require 'json'

module Storm
  class CLI
    include Mixlib::CLI

    NO_COMMAND_GIVEN = "You need to pass a URL to test (e.g. storm http://example.com/"

    banner "Usage: storm <url> (options)"

    option :log_level,
      :short => "-l LEVEL",
      :long => "--log-level LEVEL",
      :default => :warn,
      :description => "Set the log level (debug, info, warn, error, fatal",
      :proc => Proc.new { |l| l.to_sym }

    verbosity_level = 0
    option :verbosity,
      :short => '-v',
      :long => '--verbose',
      :description => "More verbose output.  Use multiple times (-vv) for additional verbosity.",
      :proc => Proc.new { verbosity_level += 1 },
      :default => 0

    option :version,
      :short => "-V",
      :long => "--version",
      :description => "Show the current version and exit.",
      :boolean => true,
      :proc => lambda {|v| puts "Storm: #{::Storm::VERSION}"},
      :exit => 0

    option :help,
      :short => "-h",
      :long => "--help",
      :description => "Show this message",
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0

    option :format,
      :short => "-f FORMAT",
      :long => "--format FORMAT",
      :description => "Output format (json, text)",
      :proc => Proc.new { |f| f.to_sym },
      :default => :text

    option :cache,
      :short => "-n",
      :long => "--no-cache",
      :description => "Disable any cache options (dns/http)",
      :boolean => false

    option :close,
      :short => "-c",
      :long => "--close",
      :description => "Add Connection: close HTTP header.",
      :boolean => false

    option :ua,
      :short => "-u USERAGENT",
      :long => "--user-agent USERAGENT",
      :description => "User Agent string (osxsafari, osxchrome, osxff, winie,
                                     winchrome, winff, iphone, ipad, androidwebkit,
                                     androidopera, blackberry)",
      :default => :osxsafari,
      :proc => Proc.new { |u| u.to_sym }

    def validate_and_parse_options
      # Checking ARGV validity *before* parse_options because parse_options
      # mangles ARGV in some situations
      if (want_help? || want_version?)
        print_help_and_exit
      elsif no_command_given?
        print_help_and_exit(1, NO_COMMAND_GIVEN)
      else
        config[:cache] = true
        do_parse
      end

      # Post-parse option validation
      if not valid_format?
        print_help_and_exit(2, "Invalid format: #{config[:format]}")
      end
      if not valid_ua?
        print_help_and_exit(3, "Invalid User Agent: #{config[:ua]}")
      end

      if not valid_uri?
        print_help_and_exit(4, "Invalid URL: #{@uri.to_s}")
      end
    end

    def no_command_given?
      ARGV.empty?
    end

    def want_help?
      ARGV[0] =~ /^(--help|-h)$/
    end

    def want_version?
      ARGV[0] =~ /^(--version|-V)$/
    end

    def valid_format?
      config[:format] =~ /^(json|text)$/
    end

    def valid_ua?
      config[:ua] =~ /^(osxsafari|osxchrome|osxff|winie|winchrome|winff|iphone|ipad|androidwebkit|androidopera|blackberry)$/
    end

    def valid_uri?
      if not @uri.scheme or not @uri.path or not @uri.host
        return false
      end
      true
    end

    def do_parse
      begin
        self.parse_options

        # Parse URI and then add in scheme and path if not given.
        @uri = URI(ARGV[0])
        if not @uri.scheme
          @uri = URI('http://' + ARGV[0])
          if @uri.path.empty?
            @uri.path = "/"
          end
        end
      rescue OptionParser::InvalidOption => e
        puts "ERROR: OptionParser => #{e}\n"
      rescue OptionParser::MissingArgument => e
        puts "ERROR: OptionParser => #{e}\n"
      end
    end

    def print_help_and_exit(exitcode=1, fatal_message=nil)
      Storm::Log.error(fatal_message) if fatal_message
      do_parse
      puts self.opt_parser
      puts
      # TODO List command options.
      # Storm::Command.list_commands
      exit exitcode
    end

    # Execute the command
    def run
      Mixlib::Log::Formatter.show_time = false
      validate_and_parse_options
      quiet_traps
      execute!
      exit 0
    end

    # Internal execute command
    def execute!
      puts "TESTING #{@uri.host}" if config[:verbosity] > 0

      tests = Hash.new

      dns = Storm::Test::DNS.new(@uri.host)
      dns.run(config)
      tests[:dns] = dns.report

      http = Storm::Test::HTTP.new(@uri, :get, nil, nil)
      http.run(config)
      tests[:http] = http.report

      case config[:format]
      when :text
        tests.each do |test, t|
          puts "#{test.upcase.to_s}:"
          t.each do |n,time|
            puts "\t#{n}: #{time}"
          end
        end
      when :json
        require 'json'
        puts tests.to_json
      end
    end

    private
    def quiet_traps
      trap("TERM") do
        exit 1
      end

      trap("INT") do
        exit 2
      end
    end
  end
end
