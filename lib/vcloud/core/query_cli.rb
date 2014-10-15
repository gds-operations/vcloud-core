require 'optparse'

module Vcloud
  module Core
    class QueryCli

      # Create a new instance of the CLI, parsing the arguments supplied
      #
      # @param argv_array [Array] The Array of ARGV arguments
      # @return [Vcloud::Core::QueryCLI]
      def initialize(argv_array)
        @usage_text = nil
        @type = nil
        @options = {}

        parse(argv_array)
      end

      # Run a query and print results to standard out
      #
      # @return [void]
      def run
        begin
          Vcloud::Core::Query.new(@type, @options).run
        rescue => e
          $stderr.puts(e)
          exit 1
        end
      end

      private

      def parse(args)
        opt_parser = OptionParser.new do |opts|
          opts.banner = <<-EOS
Usage: #{$0} [options] [type]

vcloud-query takes a query type and returns all vCloud entities of
that type, obeying supplied filter rules.

Query types map to vCloud entities, for example: vApp, vm, orgVdc, orgVdcNetwork.

Without a type argument, returns a list of available Entity Types to query.

See https://github.com/gds-operations/vcloud-tools/blob/master/README.md for more info.

Example use:

  # get a list of all vApps, returning all available parameters, in YAML

  vcloud-query -o yaml vApp

  # get a list of all powered off VMs return the name and containerName (vapp
  # name)

  vcloud-query --filter "status==POWERED_OFF" --fields name,containerName vm

  # list all query types (types are left-most column, possible formats listed
  # on the left (records is default, and most useful)

  vcloud-query
          EOS

          opts.on('-A', '--sort-asc ATTRIBUTE', 'Sort ascending') do |v|
            @options[:sortAsc] = v
          end

          opts.on('-D', '--sort-desc ATTRIBUTE', 'Sort descending') do |v|
            @options[:sortDesc] = v
          end

          opts.on('--fields NAMES', 'Attribute or metadata key names') do |v|
            @options[:fields] = v
          end

          opts.on('--filter FILTER', 'Filter expression') do |v|
            @options[:filter] = v
          end

          opts.on('-o', '--output-format FORMAT', 'Output format: csv, tsv, yaml') do |v|
            @options[:output_format] = v.downcase
          end

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

        if args.size > 1
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
