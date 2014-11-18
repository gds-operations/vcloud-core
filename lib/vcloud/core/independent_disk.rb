module Vcloud
  module Core
    class IndependentDisk

      class QueryExecutionError < RuntimeError; end
      class DiskNotFoundException < RuntimeError; end
      class MultipleDisksFoundException < RuntimeError; end
      class DiskAlreadyExistsException < RuntimeError; end

      attr_reader :id

      # Return an object referring to a particular IndependentDisk
      #
      # @param id [String] The ID of the independent disk
      # @return [Vcloud::Core::IndependentDisk]
      def initialize(id)
        unless id =~ /^[-0-9a-f]+$/
          raise "IndependentDisk id : #{id} is not in correct format"
        end
        @id = id
      end

      # Return the ID of an IndependentDisk referred to by name and vDC
      #
      # @param name [String] The name of the disk
      # @param vdc [String] The name of the vDC
      # @return [Vcloud::Core::IndependentDisk] An object representing the IndependentDisk
      def self.get_by_name_and_vdc_name(name, vdc_name)
        q = Vcloud::Core::QueryRunner.new
        query_results = q.run('disk', :filter => "name==#{name};vdcName==#{vdc_name}")
        unless query_results
          raise QueryExecutionError,
            "Error finding IndependentDisk by name '#{name}' & vdc '#{vdc_name}'"
        end
        raise DiskNotFoundException,
          "IndependentDisk '#{name}' not found in vDC '#{vdc_name}'" if query_results.size == 0
        if query_results.size > 1
          raise MultipleDisksFoundException,
            "Multiple IndependentDisks matching '#{name}' found in vDC '#{vdc_name}. " +
                "Create disks via IndependentDisk.new(disk_id) instead."
        end
        return self.new(query_results.first[:href].split('/').last)
      end

      # Create a named, sized IndependentDisk in a particular named vDC
      #
      # @param vdc [String] The name of the vDC
      # @param name [String] The name of the IndependentDisk
      # @param size [String, Integer] The size as an integer of bytes, or an
      #                               integer with units
      #                               (see convert_size_to_bytes)
      # @return [Vcloud::Core::IndependentDisk] An object representing
      #                                         the new disk
      def self.create(vdc, name, size)
        vdc_name = vdc.name
        begin
          self.get_by_name_and_vdc_name(name, vdc_name)
        rescue DiskNotFoundException
          ok_to_create = true
        end

        unless ok_to_create
          raise DiskAlreadyExistsException,
            "Cannot create Independent Disk '#{name}' in vDC '#{vdc_name}' - a disk with " +
            "that name is already present"
        end

        size_in_bytes = convert_size_to_bytes(size)
        body = Vcloud::Core::Fog::ServiceInterface.new.post_create_disk(vdc.id, name, size_in_bytes)
        return self.new(body[:href].split('/').last)
      end

      # Return all the vcloud attributes of IndependentDisk
      #
      # @return [Hash] a hash describing all the attributes of disk
      def vcloud_attributes
        Vcloud::Core::Fog::ServiceInterface.new.get_disk(id)
      end

      # Return the name of IndependentDisk
      #
      # @return [String] the name of instance
      def name
        vcloud_attributes[:name]
      end

      # Return the href of IndependentDisk
      #
      # @return [String] the href of instance
      def href
        vcloud_attributes[:href]
      end

      # Return an array of Vcloud::Core::Vm objects which are attached to
      # independent disk
      #
      # @return [Array] an array of Vcloud::Core::Vm
      def attached_vms
        body = Vcloud::Core::Fog::ServiceInterface.new.get_vms_disk_attached_to(id)
        vms = body.fetch(:VmReference)
        vms.map do |vm|
          id = vm.fetch(:href).split('/').last
          parent_vapp = Vcloud::Core::Vapp.get_by_child_vm_id(id)
          Vcloud::Core::Vm.new(id, parent_vapp)
        end
      end

      # Delete the IndependentDisk entity referred to by this object.
      #
      # @return [Boolean] Returns true if disk was deleted. Raises an exception otherwise.
      def destroy
        Vcloud::Core::Fog::ServiceInterface.new.delete_disk(id)
      end

      # Convert an integer and units suffix (e.g. 10mb) into an integer of bytes
      # Allowed suffixes are: mb, gb, mib, gib
      #
      # @param size [String] the intended size of the disk (optionally with units)
      # @return [Integer] the disk size in bytes
      def self.convert_size_to_bytes(size)
        if size.to_s =~ /^(\d+)mb$/i
          Integer($1) * (10**6)
        elsif size.to_s =~ /^(\d+)gb$/i
          Integer($1) * (10**9)
        elsif size.to_s =~ /^(\d+)mib$/i
          Integer($1) * (2**20)
        elsif size.to_s =~ /^(\d+)gib$/i
          Integer($1) * (2**30)
        elsif size.to_s =~ /^(\d+)$/i
          Integer($1)
        else
          raise ArgumentError, "Cannot convert size string '#{size}' into a number of bytes"
        end
      end

    end
  end
end
