module Vcloud
  module Core
    class EdgeGatewayInterface

      def initialize(gateway_interface_hash)
        @vcloud_gateway_interface = gateway_interface_hash
      end

      def name
        @vcloud_gateway_interface[:Name]
      end

      def network_id
        network_href.split('/').last
      end

      def network_href
        @vcloud_gateway_interface[:Network][:href]
      end

      def network_name
        @vcloud_gateway_interface[:Network][:name]
      end

    end
  end
end
