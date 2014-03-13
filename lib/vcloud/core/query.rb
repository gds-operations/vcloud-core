require 'csv'

module Vcloud
  class Query

    def initialize(type=nil, options={})
      @type = type
      @options = options
      @options[:output_format] ||= 'tsv'
      @query_runner = Vcloud::QueryRunner.new
    end

    def run()
      if @type.nil?
        output_available_query_types
      else
        output_query_results
      end
    end

  private
    def output_query_results
      results = @query_runner.run(@type, @options)
      output_header(results)
      output_results(results)
    end

    def output_available_query_types
      available_query_types = @query_runner.available_query_types

      available_queries = collate_formats_for_types(available_query_types)

      print_query_types(available_queries)
    end

    def collate_formats_for_types(available_queries)
      queries = Hash.new { |h, k| h[k]=[] }
      available_queries.each do |type, format|
        queries[type] << format
      end
      queries
    end

    def print_query_types(queries)
      type_width = longest_query_type(queries)

      queries.keys.sort.each do |type|
        puts "%-#{type_width}s %s" % [type, queries[type].sort.join(',')]
      end
    end

    def longest_query_type(queries)
      return 0 if queries.keys.empty?
      queries.keys.max_by{|key| key.length}.length
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