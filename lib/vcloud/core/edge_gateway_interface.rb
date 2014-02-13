module Vcloud
  module Core
    class EdgeGatewayInterface

      attr_accessor :name, :network_href, :network_name

      def initialize(gateway_interface_hash)
        raise "Argument error: nil not allowed" if gateway_interface_hash.nil?
        @vcloud_gateway_interface = gateway_interface_hash
        unless @name = gateway_interface_hash[:Name]
          raise "Argument error: must have a :Name"
        end
        unless network_section = gateway_interface_hash[:Network]
          raise "Argument error: must have a :Network section"
        end
        unless @network_href = network_section[:href]
          raise "Argument error: must have a :Network[:href]"
        end
        unless @network_name = network_section[:name]
          raise "Argument error: must have a :Network[:name]"
        end
      end

      def network_id
        network_href.split('/').last
      end

    end
  end
end
