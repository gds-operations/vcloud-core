require 'optparse'
require 'highline'

module Vcloud
  module Core
    class LoginCli

      # Create a new instance of the CLI, parsing the arguments supplied
      #
      # @param argv_array [Array] The Array of ARGV arguments
      # @return [Vcloud::Core::LoginCLI]
      def initialize(argv_array)
        @usage_text = nil

        parse(argv_array)
      end

      # Login to vCloud and print shell commands suitable for setting the vcloud_token
      #
      # @return [void]
      def run
        begin
          pass = read_pass
          puts Vcloud::Core::Fog::Login.token_export(pass)
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
set, but the password set to an empty string. The password can either be
entered interactively or piped in, for example from an environment variable:

    printenv PASSWORD_VAR | FOG_CREDENTIAL=example #{$0}

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

      def read_pass
        hl = HighLine.new($stdin, $stderr)
        if STDIN.tty?
          hl.ask("vCloud password: ") { |q| q.echo = "*" }
        else
          hl.ask("Reading password from pipe..")
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
