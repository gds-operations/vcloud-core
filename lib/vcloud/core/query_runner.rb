module Vcloud

  class QueryRunner
    def initialize
      @fsi = Vcloud::Fog::ServiceInterface.new
    end

    def run(type=nil, options={})
      get_all_results(type, options)
    end

    def available_query_types
      query_list = @fsi.get_execute_query
      query_list[:Link].select do |link|
        link[:rel] == 'down'
      end.map do |link|
        href  = Nokogiri::XML.fragment(link[:href])
        query = CGI.parse(URI.parse(href.text).query)
        [query['type'].first, query['format'].first]
      end
    end

  private

    def get_all_results(type, options)
      results = []
      (1..get_num_pages(type, options)).each do |page|
        results += get_results_page(page, type, options) || []
      end
      results
    end

    def get_num_pages(type, options)
      body = @fsi.get_execute_query(type, options)
      last_page = body[:lastPage] || 1
      raise "Invalid lastPage (#{last_page}) in query results" unless last_page.is_a? Integer
      return last_page.to_i
    end

    def get_results_page(page, type, options)
      raise "Must supply a page number" if page.nil?

      begin
        body = @fsi.get_execute_query(type, options.merge({:page=>page}))
      rescue ::Fog::Compute::VcloudDirector::BadRequest, ::Fog::Compute::VcloudDirector::Forbidden => e
        raise "Access denied: #{e.message}"
      end

      records = body.keys.detect {|key| key.to_s =~ /Record|Reference$/}
      body[records] = [body[records]] if body[records].is_a?(Hash)
      return nil if body[records].nil? || body[records].empty?
      body[records]
    end
  end
end