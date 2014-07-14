require 'optparse'

module Vcloud
  module Core
    class LoginCli
      def initialize(argv_array)
        @usage_text = nil

        parse(argv_array)
      end

      def run
        begin
          puts Vcloud::Core::Login.token_export
        rescue => e
          $stderr.puts(e)
          exit 1
        end
      end

      private

      def parse(args)
        opt_parser = OptionParser.new do |opts|
          opts.banner = <<-EOS
Usage: #{$0} [options]

Utility for obtaining a Fog vCloud Director session token. It will output a
shell `export` command that can be consumed with:

    eval $(FOG_CREDENTIAL=example #{$0})

It requires a Fog credentials file (e.g. `~/.fog`) with the host and user
set, but the password set to an empty string. The password will be prompted
for interactively.

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
        elsif args.size == 1
          @type = args.first
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
