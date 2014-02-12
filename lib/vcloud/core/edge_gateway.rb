module Vcloud
  module Core
    class EdgeGateway

      attr_reader :id

      def initialize(id)
        unless id =~ /^[-0-9a-f]+$/
          raise "EdgeGateway id : #{id} is not in correct format"
        end
        @id = id
      end

      def self.get_ids_by_name(name)
        q = Query.new('edgeGateway', :filter => "name==#{name}")
        unless res = q.get_all_results
          raise "Error finding edgeGateway by name #{name}"
        end
        res.collect do |record| 
          record[:href].split('/').last if record.key?(:href)
        end
      end

      def update_configuration(config)
        fsi = Vcloud::Fog::ServiceInterface.new
        fsi.post_configure_edge_gateway_services(id, config)
      end

      def vcloud_gateway_interface_by_id gateway_interface_id
        gateway_interfaces = vcloud_attributes[:Configuration][:GatewayInterfaces][:GatewayInterface]
        unless gateway_interfaces.empty?
          return gateway_interfaces.find{ |interface|
            interface[:Network][:href].split('/').last == gateway_interface_id
          }
        end
      end

      def self.get_by_name(name)
        ids = self.get_ids_by_name(name)
        raise "edgeGateway #{name} not found" if ids.size == 0
        raise "edgeGateway #{name} is not unique" if ids.size > 1
        return self.new(ids.first)
      end

      def vcloud_attributes
        fsi = Vcloud::Fog::ServiceInterface.new
        fsi.get_edge_gateway(id)
      end

      def href
        vcloud_attributes[:href]
      end

      def name
        vcloud_attributes[:name]
      end

      def interfaces
        vca = vcloud_attributes
        return [] unless gwis = vca[:Configuration][:GatewayInterfaces]
        return [] unless interfaces = gwis[:GatewayInterface]
        interfaces.map do |vcloud_attrs|
          out = {}
          out[:name] = vcloud_attrs[:Name]
          out[:interface_type] = vcloud_attrs[:InterfaceType]
          out[:network_href]   = vcloud_attrs[:Network][:href]
          out[:network_id]     = vcloud_attrs[:Network][:href].split('/').last
          out[:network_name]   = vcloud_attrs[:Network][:name]
          out
        end
      end

    end
  end
end
