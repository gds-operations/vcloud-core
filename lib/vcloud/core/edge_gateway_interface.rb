module Vcloud
  module Core
    class EdgeGatewayInterface

      attr_accessor :name, :network_href, :network_name

      def initialize(gateway_interface_hash)
        raise "Argument error: nil not allowed" if gateway_interface_hash.nil?
        raise "Argument error: must have a :Name" unless gateway_interface_hash[:Name]
        network_section = gateway_interface_hash[:Network]
        raise "Argument error: must have a :Network section" unless network_section
        raise "Argument error: must have a :Network[:href]" unless network_section[:href]
        raise "Argument error: must have a :Network[:name]" unless network_section[:name]
        @vcloud_gateway_interface = gateway_interface_hash
        @name = gateway_interface_hash[:Name]
        @network_href = network_section[:href]
        @network_name = network_section[:name]
      end

      def network_id
        network_href.split('/').last
      end

    end
  end
end
