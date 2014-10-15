module Vcloud
  module Core
    class Vdc

      attr_reader :id

      # Initialize a Vcloud::Core::Vdc
      #
      # @param id [String] the vDC ID
      # @return [Vcloud::Core::Vdc]
      def initialize(id)
        unless id =~ /^[-0-9a-f]+$/
          raise "vdc id : #{id} is not in correct format"
        end
        @id = id
      end

      # Get the ID of a named vDC
      #
      # @param name [String] The name of the vDC
      # @return [String] The ID of the vDC
      def self.get_by_name(name)
        q = Vcloud::Core::QueryRunner.new
        query_results = q.run('orgVdc', :filter => "name==#{name}")
        raise "Error finding vDC by name #{name}" unless query_results
        raise "vDc #{name} not found" unless query_results.size == 1
        return self.new(query_results.first[:href].split('/').last)
      end

      # Return the vCloud data associated with vDC
      #
      # @return [Hash] the complete vCloud data for vDC
      def vcloud_attributes
        Vcloud::Core::Fog::ServiceInterface.new.get_vdc(id)
      end

      # Return the name of vDC
      #
      # @return [String] the name of instance
      def name
        vcloud_attributes[:name]
      end

      # Return the href of vDC
      #
      # @return [String] the href of instance
      def href
        vcloud_attributes[:href]
      end

    end
  end
end
