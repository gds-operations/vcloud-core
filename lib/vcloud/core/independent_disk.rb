module Vcloud
  module Core
    class IndependentDisk

      attr_reader :id

      def initialize(id)
        unless id =~ /^[-0-9a-f]+$/
          raise "IndependentDisk id : #{id} is not in correct format"
        end
        @id = id
      end

      def self.get_by_name_and_vdc_name(name, vdc_name)
        q = Vcloud::Core::QueryRunner.new
        query_results = q.run('disk', :filter => "name==#{name};vdcName==#{vdc_name}")
        unless query_results
          raise "Error finding IndependentDisk by name '#{name}' & vdc '#{vdc_name}'"
        end
        raise "IndependentDisk '#{name}' not found in vDC '#{vdc_name}'" if query_results.size == 0
        if query_results.size > 1
          raise "Multiple IndependentDisks matching '#{name}' found in vDC '#{vdc_name}. " +
                "You must specify via ID instead."
        end
        return self.new(query_results.first[:href].split('/').last)
      end

      def vcloud_attributes
        Vcloud::Core::Fog::ServiceInterface.new.get_disk(id)
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
