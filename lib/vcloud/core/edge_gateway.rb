module Vcloud
  module Core
    class EdgeGateway

      attr_reader :id

      # Initialize a new EdgeGateway and check that the provided ID
      # is in the correct format (lowercase string containing
      # hexadecimal characters or hyphens)
      #
      # @param id [String] The ID of gateway
      # @return [Vcloud::Core::EdgeGateway] an instance of an EdgeGateway
      def initialize(id)
        unless id =~ /^[-0-9a-f]+$/
          raise "EdgeGateway id : #{id} is not in correct format"
        end
        @id = id
      end

      # Find a list of EdgeGateway IDs that match a name
      #
      # @param name [String] The name of the EdgeGateway
      # @return [Array] An array of IDs found.
      def self.get_ids_by_name(name)
        q = Vcloud::Core::QueryRunner.new
        query_results = q.run('edgeGateway', :filter => "name==#{name}")
        raise "Error finding edgeGateway by name #{name}" unless query_results
        query_results.collect do |record|
          record[:href].split('/').last if record.key?(:href)
        end
      end


      # Update configuration for EdgeGateway
      #
      # @param config [Hash] A configuration for EdgeGateway
      def update_configuration(config)
        fsi = Vcloud::Core::Fog::ServiceInterface.new
        fsi.post_configure_edge_gateway_services(id, config)
      end


      # Return the Vcloud::Core::EdgeGatewayInterface of EdgeGateway which matches an ID
      #
      # @param id [String] The id of the EdgeGatewayInterface
      # @return [Vcloud::Core::EdgeGatewayInterface] the EdgeGatewayInterface instance
      def vcloud_gateway_interface_by_id gateway_interface_id
        gateway_interfaces = vcloud_attributes[:Configuration][:GatewayInterfaces][:GatewayInterface]
        unless gateway_interfaces.empty?
          return gateway_interfaces.find{ |interface|
            interface[:Network][:href].split('/').last == gateway_interface_id
          }
        end
      end

      # Return the EdgeGateway instance that is the first match for the
      # supplied name.
      #
      # @param name [String] The name of the EdgeGateway
      # @return [Vcloud::Core::EdgeGateway] the EdgeGateway instance
      def self.get_by_name(name)
        ids = self.get_ids_by_name(name)
        raise "edgeGateway #{name} not found" if ids.size == 0
        raise "edgeGateway #{name} is not unique" if ids.size > 1
        return self.new(ids.first)
      end

      # Get the vCloud attributes for EdgeGateway
      #
      # @return [String] Excon::Response#body from vCloud for EdgeGateway
      def vcloud_attributes
        fsi = Vcloud::Core::Fog::ServiceInterface.new
        fsi.get_edge_gateway(id)
      end

      # Return the +href+ of EdgeGateway
      #
      # @return [String] href of EdgeGateway
      def href
        vcloud_attributes[:href]
      end

      # Return the +name+ of EdgeGateway
      #
      # @return [String] name of EdgeGateway
      def name
        vcloud_attributes[:name]
      end

      # For each GatewayInterfaces item in the configuration, create an
      # EdgeGatewayInterface object to allow decisions based on the connected
      # networks to be taken without inspecting the API details.
      #
      # @return [Array] An array of Vcloud::Core::EdgeGatewayInterface objects
      def interfaces
        gateway_config = vcloud_attributes[:Configuration]
        return [] unless gateway_config[:GatewayInterfaces]
        gateway_interfaces = gateway_config[:GatewayInterfaces][:GatewayInterface]
        return [] unless gateway_interfaces
        gateway_interfaces.map do |vcloud_gateway_interface_hash|
          EdgeGatewayInterface.new(vcloud_gateway_interface_hash)
        end
      end

    end
  end
end
