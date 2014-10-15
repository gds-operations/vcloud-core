module Vcloud
  module Core
    class Vm
      extend ComputeMetadata

      attr_reader :id

      # Initialize a Vcloud::Core::Vm within a vApp
      #
      # @param id [String] the VM ID
      # @param vapp [Vcloud::Core::Vapp] The vApp object to create VM in
      # @return [Vcloud::Core::Vm]
      def initialize(id, vapp)
        unless id =~ /^#{self.class.id_prefix}-[-0-9a-f]+$/
          raise "#{self.class.id_prefix} id : #{id} is not in correct format"
        end
        @id = id
        @vapp = vapp
      end

      # Return the vCloud data associated with VM
      #
      # @return [Hash] the complete vCloud data for VM
      def vcloud_attributes
        Vcloud::Core::Fog::ServiceInterface.new.get_vapp(id)
      end

      # Set the amount of memory in VM which can't be nil or less than 64 (mb)
      #
      # @param new_memory [Integer] amount of memory for instance
      # @return [void]
      def update_memory_size_in_mb(new_memory)
        return if new_memory.nil?
        return if new_memory.to_i < 64
        unless memory.to_i == new_memory.to_i
          Vcloud::Core::Fog::ServiceInterface.new.put_memory(id, new_memory)
        end
      end

      # Return the amount of memory allocated to VM
      #
      # @return [Integer] amount of memory in megabytes
      def memory
        memory_item = virtual_hardware_section.detect { |i| i[:'rasd:ResourceType'] == '4' }
        memory_item[:'rasd:VirtualQuantity']
      end

      # Return the number of CPUs allocated to the VM
      #
      # @return [Integer] number of virtual CPUs
      def cpu
        cpu_item = virtual_hardware_section.detect { |i| i[:'rasd:ResourceType'] == '3' }
        cpu_item[:'rasd:VirtualQuantity']
      end

      # Return the name of VM
      #
      # @return [String] the name of instance
      def name
        vcloud_attributes[:name]
      end

      # Return the href of VM
      #
      # @return [String] the href of instance
      def href
        vcloud_attributes[:href]
      end

      # Update the name of VM
      #
      # @param new_name [String] The new name for the VM
      # @return [void]
      def update_name(new_name)
        fsi = Vcloud::Core::Fog::ServiceInterface.new
        fsi.put_vm(id, new_name) unless name == new_name
      end

      # Return the name of the vApp containing VM
      #
      # @return [String] the name of the vApp
      def vapp_name
        @vapp.name
      end

      # Update the number of CPUs in VM
      #
      # @param new_cpu_count [Integer] The number of virtual CPUs to allocate
      # @return [void]
      def update_cpu_count(new_cpu_count)
        return if new_cpu_count.nil?
        return if new_cpu_count.to_i == 0
        unless cpu.to_i == new_cpu_count.to_i
          Vcloud::Core::Fog::ServiceInterface.new.put_cpu(id, new_cpu_count)
        end
      end

      # Update the metadata for VM
      #
      # @param metadata [Hash] hash of keys, values to set
      # @return [void]
      def update_metadata(metadata)
        return if metadata.nil?
        fsi = Vcloud::Core::Fog::ServiceInterface.new
        metadata.each do |k, v|
          fsi.put_vapp_metadata_value(@vapp.id, k, v)
          fsi.put_vapp_metadata_value(id, k, v)
        end
      end

      # Attach independent disk(s) to VM
      #
      # @param disk_list [Array] an array of Vcloud::Core::IndependentDisk objects
      # @return [void]
      def attach_independent_disks(disk_list)
        disk_list = Array(disk_list) # ensure we have an array
        disk_list.each do |disk|
          Vcloud::Core::Fog::ServiceInterface.new.post_attach_disk(id, disk.id)
        end
      end

      # Detach independent disk(s) from VM
      #
      # @param disk_list [Array] an array of Vcloud::Core::IndependentDisk objects
      # @return [void]
      def detach_independent_disks(disk_list)
        disk_list = Array(disk_list) # ensure we have an array
        disk_list.each do |disk|
          Vcloud::Core::Fog::ServiceInterface.new.post_detach_disk(id, disk.id)
        end
      end

      # Add extra disks to VM
      #
      # @param extra_disks [Array] An array of hashes like [{ size: '20480' }]
      # @return [void]
      def add_extra_disks(extra_disks)
        vm = Vcloud::Core::Fog::ModelInterface.new.get_vm_by_href(href)
        if extra_disks
          extra_disks.each do |extra_disk|
            Vcloud::Core.logger.debug("adding a disk of size #{extra_disk[:size]}MB into VM #{id}")
            vm.disks.create(extra_disk[:size])
          end
        end
      end

      # Configure VM network interfaces
      #
      # @param networks_config [Array] An array of hashes like [{ :name => 'NetworkName' }]
      # @return [void]
      def configure_network_interfaces(networks_config)
        return unless networks_config
        section = {PrimaryNetworkConnectionIndex: 0}
        section[:NetworkConnection] = networks_config.compact.each_with_index.map do |network, i|
          connection = {
              network: network[:name],
              needsCustomization: true,
              NetworkConnectionIndex: i,
              IsConnected: true
          }
          ip_address      = network[:ip_address]
          allocation_mode = network[:allocation_mode]

          allocation_mode = 'manual' if ip_address
          allocation_mode = 'dhcp' unless %w{dhcp manual pool}.include?(allocation_mode)

          connection[:IpAddressAllocationMode] = allocation_mode.upcase
          connection[:IpAddress] = ip_address if ip_address
          connection
        end
        Vcloud::Core::Fog::ServiceInterface.new.put_network_connection_system_section_vapp(id, section)
      end

      # Configure guest customisation script
      #
      # @param preamble [String] A script to run when the VM is created
      # @return [void]
      def configure_guest_customization_section(preamble)
        Vcloud::Core::Fog::ServiceInterface.new.put_guest_customization_section(id, vapp_name, preamble)
      end

      # Update the storage profile of a VM
      #
      # @param storage_profile [String] The name of the storage profile
      # @return [void]
      def update_storage_profile storage_profile
        storage_profile_href = get_storage_profile_href_by_name(storage_profile, @vapp.name)
        Vcloud::Core::Fog::ServiceInterface.new.put_vm(id, name, {
          :StorageProfile => {
            name: storage_profile,
            href: storage_profile_href
          }
        })
      end

      private

      def virtual_hardware_section
        vcloud_attributes[:'ovf:VirtualHardwareSection'][:'ovf:Item']
      end

      def get_storage_profile_href_by_name(storage_profile_name, vapp_name)
        q = Vcloud::Core::QueryRunner.new
        vdc_results = q.run('vApp', :filter => "name==#{vapp_name}")
        vdc_name = vdc_results.first[:vdcName]

        q = Vcloud::Core::QueryRunner.new
        sp_results = q.run('orgVdcStorageProfile', :filter => "name==#{storage_profile_name};vdcName==#{vdc_name}")

        if sp_results.empty? or !sp_results.first.has_key?(:href)
          raise "storage profile not found"
        else
          return sp_results.first[:href]
        end
      end

      def self.id_prefix
        'vm'
      end

    end

  end
end
