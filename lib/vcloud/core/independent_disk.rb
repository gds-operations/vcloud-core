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

      def self.create(vdc, name, size)
        size_in_bytes = convert_size_string_to_bytes(size)
        body = Vcloud::Core::Fog::ServiceInterface.new.post_upload_disk(vdc.id, name, size_in_bytes)
        return self.new(body[:href].split('/').last)
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

      def self.convert_size_string_to_bytes(size)
        if size.to_s =~ /^(\d+)mb$/i
          Integer($1) * (10**6)
        elsif size.to_s =~ /^(\d+)gb$/i
          Integer($1) * (10**9)
        elsif size.to_s =~ /^(\d+)mib$/i
          Integer($1) * (2**20)
        elsif size.to_s =~ /^(\d+)gib$/i
          Integer($1) * (2**30)
        elsif size.to_s =~ /^(\d+)$/i
          Integer($1)
        else
          raise ArgumentError, "Cannot convert size string '#{size}' into a number of bytes"
        end
      end

    end
  end
end
