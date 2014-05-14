module Vcloud
  module Core
    class EdgeGatewayInterface

      attr_accessor :name, :network_href, :network_name

      def initialize(gateway_interface_hash)
        if gateway_interface_hash.nil?
          raise "EdgeGatewayInterface: gateway_interface_hash cannot be nil" 
        end
        unless gateway_interface_hash[:Name] && gateway_interface_hash[:Network]
          raise "EdgeGatewayInterface: bad input: #{gateway_interface_hash}"
        end
        @vcloud_gateway_interface = gateway_interface_hash
        @name = gateway_interface_hash[:Name]
        @network_href = gateway_interface_hash[:Network][:href]
        @network_name = gateway_interface_hash[:Network][:name]
      end

      def network_id
        network_href.split('/').last
      end

    end
  end
end
