require 'optparse'

module Vcloud
  module Core
    class LogoutCli

      # Create a new instance of the CLI, parsing the arguments supplied
      #
      # @param argv_array [Array] The Array of ARGV arguments
      # @return [Vcloud::Core::LogoutCLI]
      def initialize(argv_array)
        @usage_text = nil

        parse(argv_array)
      end

      # Logout an existing vCloud session.
      #
      # @return [void]
      def run
        begin
          Vcloud::Core::Fog.logout
        rescue => e
          $stderr.puts("#{e.class}: #{e.message}")
          exit 1
        end
      end

      private

      def parse(args)
        opt_parser = OptionParser.new do |opts|
          opts.banner = <<-EOS
Usage: #{$0} [options]

Utility for logging out of a vCloud session and preventing future use of the
session token. A `FOG_VCLOUD_TOKEN` environment variable, as provided by
`vcloud-login`, must be present.

          EOS

          opts.on("-h", "--help", "Print usage and exit") do
            $stderr.puts opts
            exit
          end

          opts.on("--version", "Display version and exit") do
            puts Vcloud::Core::VERSION
            exit
          end
        end

        @usage_text = opt_parser.to_s
        begin
          opt_parser.parse!(args)
        rescue OptionParser::InvalidOption => e
          exit_error_usage(e)
        end

        if args.size > 0
          exit_error_usage("too many arguments")
        end
      end

      def exit_error_usage(error)
        $stderr.puts "#{$0}: #{error}"
        $stderr.puts @usage_text
        exit 2
      end
    end
  end
end
