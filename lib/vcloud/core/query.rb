require 'csv'

module Vcloud
  class Query

    def initialize(type=nil, options={})
      @type = type
      @options = options
      @options[:output_format] ||= 'tsv'
      @vcloud_query_runner = Vcloud::QueryRunner.new
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
      results = @vcloud_query_runner.run(@type, @options)
      output_header(results)
      output_results(results)
    end

    def output_available_query_types
      queries = {}
      type_width = 0

      @vcloud_query_runner.available_query_types.each do |type, format|
        queries[type] ||= []
        queries[type] << format
        type_width = [type_width, type.size].max
      end
      queries.keys.sort.each do |type|
        puts "%-#{type_width}s %s" % [type, queries[type].sort.join(',')]
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