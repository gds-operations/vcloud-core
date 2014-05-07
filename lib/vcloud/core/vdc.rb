module Vcloud
  module Core
    class Vdc

      attr_reader :id

      def initialize(id)
        unless id =~ /^[-0-9a-f]+$/
          raise "vdc id : #{id} is not in correct format"
        end
        @id = id
      end

      def self.get_by_name(name)
        q = Vcloud::Core::QueryRunner.new
        query_results = q.run('orgVdc', :filter => "name==#{name}")
        raise "Error finding vDC by name #{name}" unless query_results
        raise "vDc #{name} not found" unless query_results.size == 1
        return self.new(query_results.first[:href].split('/').last)
      end

      def vcloud_attributes
        Vcloud::Fog::ServiceInterface.new.get_vdc(id)
      end

      def name
        vcloud_attributes[:name]
      end

      def href
        vcloud_attributes[:href]
      end

    end
  end
end
