module Vcloud
  module Core
    class Vapp
      extend ComputeMetadata

      attr_reader :id

      # Initialize a Vcloud::Core::Vapp
      #
      # @param id [String] the vApp ID
      # @return [Vcloud::Core::Vapp]
      def initialize(id)
        unless id =~ /^#{self.class.id_prefix}-[-0-9a-f]+$/
          raise "#{self.class.id_prefix} id : #{id} is not in correct format"
        end
        @id = id
      end

      # Return the ID of a named vApp
      #
      # @param name [String] the name of the vApp to find
      # @return [String] the vApp ID
      def self.get_by_name(name)
        q = Vcloud::Core::QueryRunner.new
        query_results = q.run('vApp', :filter => "name==#{name}")
        raise "Error finding vApp by name #{name}" unless query_results
        case query_results.size
        when 0
          raise "vApp #{name} not found"
        when 1
          return self.new(query_results.first[:href].split('/').last)
        else
          raise "found multiple vApp entities with name #{name}!"
        end
      end

      # Return the ID of the vApp which contains a particular VM
      #
      # @param vm_id [String] the ID of the VM to find the parent for
      # @return [String] the vApp ID
      def self.get_by_child_vm_id(vm_id)
        raise ArgumentError, "Must supply a valid Vm id" unless vm_id =~ /^vm-[-0-9a-f]+$/
        vm_body = Vcloud::Core::Fog::ServiceInterface.new.get_vapp(vm_id)
        parent_vapp_link = vm_body.fetch(:Link).detect do |link|
          link[:rel] == Fog::RELATION::PARENT && link[:type] == Fog::ContentTypes::VAPP
        end
        unless parent_vapp_link
          raise RuntimeError, "Could not find parent vApp for VM '#{vm_id}'"
        end
        return self.new(parent_vapp_link.fetch(:href).split('/').last)
      end

      # Return the vCloud data associated with vApp
      #
      # @return [Hash] the complete vCloud data for vApp
      def vcloud_attributes
        Vcloud::Core::Fog::ServiceInterface.new.get_vapp(id)
      end

      module STATUS
        RUNNING = 4
        POWERED_OFF = 8
      end

      # Return the name of vApp
      #
      # @return [String] the name of instance
      def name
        vcloud_attributes[:name]
      end

      # Return the href of vApp
      #
      # @return [String] the href of instance
      def href
        vcloud_attributes[:href]
      end

      # Return the ID of the vDC containing vApp
      #
      # @return [String] the ID of the vDC containing vApp
      def vdc_id
        link = vcloud_attributes[:Link].detect { |l| l[:rel] == Fog::RELATION::PARENT && l[:type] == Fog::ContentTypes::VDC }
        link ? link[:href].split('/').last : raise('a vapp without parent vdc found')
      end

      # Return the VMs within vApp
      #
      # @return [Hash] the VMs contained in the vApp
      def vms
        vcloud_attributes[:Children][:Vm]
      end

      # Return the networks connected to vApp
      #
      # @return [Hash] a hash describing the networks
      def networks
        vcloud_attributes[:'ovf:NetworkSection'][:'ovf:Network']
      end

      # Find a vApp by name and vDC
      #
      # @param name [String] name of the vApp to find
      # @param vdc_name [String] name of the vDC
      # @return [String] the ID of the instance
      def self.get_by_name_and_vdc_name(name, vdc_name)
        fog_interface = Vcloud::Core::Fog::ServiceInterface.new
        attrs = fog_interface.get_vapp_by_name_and_vdc_name(name, vdc_name)
        self.new(attrs[:href].split('/').last) if attrs && attrs.key?(:href)
      end

      # Instantiate a vApp
      #
      # @param name [String] Name to use when creating the vApp
      # @param network_names [Array] Array of Strings with names of Networks to connect to the vApp
      # @param template_id [String] The ID of the template to use when creating the vApp
      # @param vdc_name [String] The name of the vDC to create vApp in
      # @return [String] the id of the created vApp
      def self.instantiate(name, network_names, template_id, vdc_name)
        Vcloud::Core.logger.info("Instantiating new vApp #{name} in vDC '#{vdc_name}'")
        fog_interface = Vcloud::Core::Fog::ServiceInterface.new
        networks = get_networks(network_names, vdc_name)

        attrs = fog_interface.post_instantiate_vapp_template(
            fog_interface.vdc(vdc_name),
            template_id,
            name,
            InstantiationParams: build_network_config(networks)
        )
        self.new(attrs[:href].split('/').last) if attrs and attrs.key?(:href)
      end

      # Update custom_fields for vApp
      #
      # @param custom_fields [Array] Array of Hashes describing the custom fields
      # @return [void] 
      def update_custom_fields(custom_fields)
        return if custom_fields.nil?
        fields = custom_fields.collect do |field|
          user_configurable = field[:user_configurable] || true
          type              = field[:type] || 'string'
          password          = field[:password] || false

          {
            :id                => field[:name],
            :value             => field[:value],
            :user_configurable => user_configurable,
            :type              => type,
            :password          => password
          }
        end

        Vcloud::Core.logger.debug("adding custom fields #{fields.inspect} to vapp #{@id}")
        Vcloud::Core::Fog::ServiceInterface.new.put_product_sections(@id, fields)
      end

      # Power on vApp
      #
      # @return [Boolean] Returns true if the VM is running, false otherwise
      def power_on
        raise "Cannot power on a missing vApp." unless id
        return true if running?
        Vcloud::Core::Fog::ServiceInterface.new.power_on_vapp(id)
        running?
      end

      private
      def running?
        raise "Cannot call running? on a missing vApp." unless id
        vapp = Vcloud::Core::Fog::ServiceInterface.new.get_vapp(id)
        vapp[:status].to_i == STATUS::RUNNING ? true : false
      end

      def self.build_network_config(networks)
        return {} unless networks
        instantiation = { NetworkConfigSection: {NetworkConfig: []} }
        networks.compact.each do |network|
          instantiation[:NetworkConfigSection][:NetworkConfig] << {
              networkName: network[:name],
              Configuration: {
                  ParentNetwork: {href: network[:href]},
                  FenceMode: 'bridged',
              }
          }
        end
        instantiation
      end

      def self.id_prefix
        'vapp'
      end

      def self.get_networks(network_names, vdc_name)
        fsi = Vcloud::Core::Fog::ServiceInterface.new
        fsi.find_networks(network_names, vdc_name) if network_names
      end
    end
  end
end
