require 'csv'

module Vcloud
  module Core
    class Query

      # Initialize a new Vcloud::Core::Query object
      #
      # @param type [String] Restrict query results to this type (see QueryRunner#available_query_types)
      # @param options [Hash] key :output_type defines the output type and defaults to tsv; csv and yaml are valid options
      # @param query_runner [Method] default=Vcloud::Core::QueryRunner.new
      # @return [Vcloud::Core::Query]
      def initialize(type=nil, options={}, query_runner = Vcloud::Core::QueryRunner.new)
        @type = type
        @options = options
        @options[:output_format] ||= 'tsv'
        @query_runner = query_runner
      end

      # Run the query and print to standard out
      #
      # @return [void]
      def run()
        if @type.nil?
          output_available_query_types
        else
          output_query_results
        end
      end

      # <b>DEPRECATED:</b> Please use <tt>Vcloud::Core::QueryRunner.run</tt> instead.
      def get_all_results
        warn "[DEPRECATION] `Vcloud::Core::Query::get_all_results` is deprecated.  Please use `Vcloud::Core::QueryRunner.run` instead."
        @query_runner.run(@type, @options)
      end

    private
      def output_query_results
        results = @query_runner.run(@type, @options)
        output_header(results)
        output_results(results)
      end

      def output_available_query_types
        @query_runner.available_query_types.each do |entity_type|
          puts entity_type
        end
      end

      def output_header(results)
        return if results.size == 0
        case @options[:output_format]
        when 'csv'
          csv_string = CSV.generate do |csv|
            csv << results.first.keys
          end
          puts csv_string
        when 'tsv'
          puts results.first.keys.join("\t")
        end
      end

      def output_results(results)
        return if results.size == 0

        case @options[:output_format]
        when 'yaml'
          puts YAML.dump(results)
        when 'csv'
          csv_string = CSV.generate do |csv|
            results.each do |record|
              csv << record.values
            end
          end
          puts csv_string
        when 'tsv'
          puts results.first.keys.join("\t") if @options[:page] == 1
          results.each do |record|
            puts record.values.join("\t")
          end
        else
          raise "Unsupported output format #{@options[:output_format]}"
        end
      end

    end
  end
end
