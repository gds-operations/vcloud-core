module Vcloud
  module Core
    class OrgVdcNetwork

      attr_reader :id

      # Return an object referring to a particular OrgVdcNetwork
      #
      # @param id [String] The ID of the network
      # @return [Vcloud::Core::OrgVdcNetwork]
      def initialize(id)
        unless id =~ /^[-0-9a-f]+$/
          raise "orgVdcNetwork id : #{id} is not in correct format"
        end
        @id = id
      end

      # Configure OrgVdcNetwork
      #
      # @param config [Hash] the configuration to apply to network
      # @return [Vcloud::Core::OrgVdcNetwork] an object referring to network
      def self.provision(config)
        raise "Must specify a name" unless config[:name]
        raise "Must specify a vdc_name" unless config[:vdc_name]
        unless config[:fence_mode] == 'isolated' || config[:fence_mode] == 'natRouted'
          raise "fence_mode #{config[:fence_mode]} not supported. Must be 'isolated' or 'natRouted'"
        end

        name = config[:name]
        vdc_name = config[:vdc_name]

        config[:is_shared] = false unless config[:is_shared]

        if config[:fence_mode] == 'natRouted'
          raise "Must specify an edge_gateway to connect to" unless config.key?(:edge_gateway)
          edgegw = Vcloud::Core::EdgeGateway.get_by_name(config[:edge_gateway])
        end

        vdc = Vcloud::Core::Vdc.get_by_name(vdc_name)

        options = construct_network_options(config)
        options[:EdgeGateway] = { :href => edgegw.href } if edgegw

        begin
          Vcloud::Core.logger.info("Provisioning new OrgVdcNetwork #{name} in vDC '#{vdc_name}'")
          attrs = Vcloud::Core::Fog::ServiceInterface.new.post_create_org_vdc_network(vdc.id, name, options)
        rescue RuntimeError => e
          Vcloud::Core.logger.error("Could not provision orgVdcNetwork: #{e.message}")
        end

        raise "Did not successfully create orgVdcNetwork" unless attrs && attrs.key?(:href)
        self.new(attrs[:href].split('/').last)

      end

      # Return all the vcloud attributes of OrgVdcNetwork
      #
      # @return [Hash] a hash describing all the attributes of OrgVdcNetwork
      def vcloud_attributes
        Vcloud::Core::Fog::ServiceInterface.new.get_network_complete(id)
      end

      # Return the name of OrgVdcNetwork
      #
      # @return [String] the name of instance
      def name
        vcloud_attributes[:name]
      end

      # Return the href of OrgVdcNetwork
      #
      # @return [String] the href of instance
      def href
        vcloud_attributes[:href]
      end

      # Delete OrgVdcNetwork
      #
      # @return [void]
      def delete
        Vcloud::Core::Fog::ServiceInterface.new.delete_network(id)
      end

      def self.construct_network_options(config)
        opts = {}
        opts[:Description] = config[:description] if config.key?(:description)
        opts[:IsShared] = config[:is_shared]

        ip_scope = {}
        ip_scope[:IsInherited] = config[:is_inherited] || false
        ip_scope[:Gateway]     = config[:gateway] if config.key?(:gateway)
        ip_scope[:Netmask]     = config[:netmask] if config.key?(:netmask)
        ip_scope[:Dns1]        = config[:dns1] if config.key?(:dns1)
        ip_scope[:Dns2]        = config[:dns2] if config.key?(:dns2)
        ip_scope[:DnsSuffix]   = config[:dns_suffix] if config.key?(:dns_suffix)
        ip_scope[:IsEnabled]   = config[:is_enabled] || true

        if config.key?(:ip_ranges) && config[:ip_ranges].size > 0
          ip_scope[:IpRanges] = []
          config[:ip_ranges].each do |range|
            ip_scope[:IpRanges] << {
              :IpRange => {
                :StartAddress => range[:start_address],
                :EndAddress   => range[:end_address]
              }
            }
          end
        end

        opts[:Configuration] = {
          :FenceMode => config[:fence_mode],
          :IpScopes => {
            :IpScope => ip_scope
          },
        }

        opts
      end

    end
  end
end
