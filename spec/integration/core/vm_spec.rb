require 'spec_helper'

describe Vcloud::Core::Vm do

  before(:all) do
    config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
    test_data = Vcloud::Tools::Tester::TestParameters.new(config_file)
    @vdc_name = test_data.vdc_1_name
    @catalog_name = test_data.catalog
    @vapp_template_name = test_data.vapp_template
    @network_names = [ test_data.network_1, test_data.network_2 ]
    @network_ips = {
      test_data.network_1 => test_data.network_1_ip,
      test_data.network_2 => test_data.network_2_ip,
    }
    @default_storage_profile_name = test_data.default_storage_profile_name
    @new_storage_profile_name = test_data.storage_profile
    @test_case_vapps = IntegrationHelper.create_test_case_vapps(
      1,
      @vdc_name,
      @catalog_name,
      @vapp_template_name,
      @network_names,
      "vcloud-core-vm-tests"
    )
    @vapp = @test_case_vapps.first
    vapp_vms = @vapp.fog_vms.map do |fog_vm|
      vm_id = fog_vm[:href].split('/').last
      Vcloud::Core::Vm.new(vm_id, @vapp)
    end
    @vm = vapp_vms.first
  end

  context "#vcloud_attributes" do

    it "has a :href element containing the expected VM id" do
      expect(@vm.vcloud_attributes[:href].split('/').last).to eq(@vm.id)
    end

  end

  context "#update_memory_size_in_mb" do

    it "can increase the memory size by 512MB" do
      initial_memory_size = Integer(@vm.memory)  # Vm#memory returns a string
      memory_to_add_in_mb = 512
      new_memory_size = initial_memory_size + memory_to_add_in_mb
      @vm.update_memory_size_in_mb(new_memory_size)
      expect(Integer(@vm.memory)).to eq(new_memory_size)
    end

    it "can reduce the memory size by 512MB" do
      initial_memory_size = Integer(@vm.memory)  # Vm#memory returns a string
      memory_to_remove_in_mb = 512
      new_memory_size = initial_memory_size - memory_to_remove_in_mb
      @vm.update_memory_size_in_mb(new_memory_size)
      expect(Integer(@vm.memory)).to eq(new_memory_size)
    end

  end

  context "#update_name" do

    it "can update the name of the vm" do
      current_name = @vm.name
      new_name = "#{current_name}-updated"
      @vm.update_name(new_name)
      expect(@vm.name).to eq(new_name)
    end

  end

  context "#vapp_name" do

    it "can retrieve the name of its parent vApp" do
      expect(@vm.vapp_name).to eq(@vapp.name)
    end

  end

  context "#update_cpu_count" do

    it "can increase the number of CPUs in a VM" do
      initial_cpu_count = Integer(@vm.cpu) # Vm#cpu returns a string :(
      new_cpu_count = initial_cpu_count * 2
      @vm.update_cpu_count(new_cpu_count)
      expect(Integer(@vm.cpu)).to eq(new_cpu_count)
    end

    it "can decrease the number of CPUs in a VM to 1" do
      initial_cpu_count = Integer(@vm.cpu) # Vm#cpu returns a string :(
      new_cpu_count = 1
      @vm.update_cpu_count(new_cpu_count)
      expect(new_cpu_count).not_to eq(initial_cpu_count)
      expect(Integer(@vm.cpu)).to eq(new_cpu_count)
    end

  end

  context "#update_metadata" do

    before(:all) do
      @initial_vm_metadata = Vcloud::Core::Vm.get_metadata(@vm.id)
      @initial_vapp_metadata = Vcloud::Core::Vapp.get_metadata(@vapp.id)
    end

    it "updates the Vm metadata, if a single key/value is specified" do
      @vm.update_metadata({"Test Key" => "test value"})
      updated_metadata = Vcloud::Core::Vm.get_metadata(@vm.id)
      # get_metadata is symbolizing the key names
      expected_metadata = @initial_vm_metadata.merge({
        :"Test Key" => "test value"
      })
      expect(updated_metadata).to eq(expected_metadata)
    end

    it "adds to the existing Vm metadata, rather than replacing it" do
      @vm.update_metadata({"Another Test" => "test value 2"})
      updated_metadata = Vcloud::Core::Vm.get_metadata(@vm.id)
      # get_metadata is symbolizing the key names
      expected_metadata = @initial_vm_metadata.merge({
        :"Test Key" => "test value",
        :"Another Test" => "test value 2",
      })
      expect(updated_metadata).to eq(expected_metadata)
    end

    it "has also updated parent vApp with the same metadata" do
      updated_vapp_metadata = Vcloud::Core::Vapp.get_metadata(@vapp.id)
      # get_metadata is symbolizing the key names
      expected_vapp_metadata = @initial_vapp_metadata.merge({
        :"Test Key" => "test value",
        :"Another Test" => "test value 2",
      })
      expect(updated_vapp_metadata).to eq(expected_vapp_metadata)
    end

  end

  context "#add_extra_disks" do

    before(:all) do
      @fog_model_vm = Vcloud::Fog::ModelInterface.new.get_vm_by_href(@vm.href)
      @initial_vm_disks = get_vm_hard_disks(@fog_model_vm)
    end

    it "the VM should already have a single disk assigned" do
      expect(@initial_vm_disks.size).to eq(1)
    end

    it "can successfully add a second disk" do
      extra_disks = [ { size: '20480' } ]
      @vm.add_extra_disks(extra_disks)
      updated_vm_disks = get_vm_hard_disks(@fog_model_vm)
      expect(updated_vm_disks.size).to eq(2)
    end

    it "can successfully add several disks in one call" do
      extra_disks = [ { size: '20480' }, { size: '10240' } ]
      disks_before_update = get_vm_hard_disks(@fog_model_vm)
      @vm.add_extra_disks(extra_disks)
      disks_after_update = get_vm_hard_disks(@fog_model_vm)
      expect(disks_after_update.size).to eq(disks_before_update.size + extra_disks.size)
    end

  end

  context "#configure_network_interfaces" do

    it "can configure a single NIC, default DHCP" do
      network_config = [
        { :name => @network_names[0] }
      ]
      @vm.configure_network_interfaces(network_config)
      # if number if nics is 1, API returns a Hash.
      # This is a bug in Fog -- ensure_list! is needed. See
      # https://github.com/fog/fog/issues/2927
      vm_nics = @vm.vcloud_attributes[:NetworkConnectionSection][:NetworkConnection]
      expect(vm_nics).to be_instance_of(Hash)
      expect(vm_nics[:network]).to eq(network_config[0][:name])
      expect(vm_nics[:IpAddressAllocationMode]).to eq('DHCP')
    end

    it "can configure dual NICs, both defaulting to DHCP" do
      network_config = [
        { :name => @network_names[0] },
        { :name => @network_names[1] }
      ]
      @vm.configure_network_interfaces(network_config)
      # if number if nics is 2+, API returns a Array.
      # See https://github.com/fog/fog/issues/2927
      vm_nics = @vm.vcloud_attributes[:NetworkConnectionSection][:NetworkConnection]
      vm_nics = sort_nics_based_on_network_connection_index(vm_nics)
      expect(vm_nics).to be_instance_of(Array)
      expect(vm_nics.size).to eq(network_config.size)
      expect(vm_nics[0][:network]).to eq(network_config[0][:name])
      expect(vm_nics[0][:IpAddressAllocationMode]).to eq('DHCP')
      expect(vm_nics[0][:NetworkConnectionIndex]).to eq('0')
      expect(vm_nics[1][:network]).to eq(network_config[1][:name])
      expect(vm_nics[1][:IpAddressAllocationMode]).to eq('DHCP')
      expect(vm_nics[1][:NetworkConnectionIndex]).to eq('1')
    end

    it "can configure dual NICs with manually assigned IP addresses" do
      network_config = [
        { :name => @network_names[0], :ip_address => @network_ips[@network_names[0]] },
        { :name => @network_names[1], :ip_address => @network_ips[@network_names[1]] },
      ]
      @vm.configure_network_interfaces(network_config)
      # if number if nics is 2+, API returns a Array.
      vm_nics = @vm.vcloud_attributes[:NetworkConnectionSection][:NetworkConnection]
      vm_nics = sort_nics_based_on_network_connection_index(vm_nics)
      expect(vm_nics).to be_instance_of(Array)
      expect(vm_nics.size).to eq(network_config.size)
      expect(vm_nics[0][:network]).to eq(network_config[0][:name])
      expect(vm_nics[0][:IpAddress]).to eq(network_config[0][:ip_address])
      expect(vm_nics[0][:IpAddressAllocationMode]).to eq('MANUAL')
      expect(vm_nics[0][:NetworkConnectionIndex]).to eq('0')
      expect(vm_nics[1][:network]).to eq(network_config[1][:name])
      expect(vm_nics[1][:IpAddress]).to eq(network_config[1][:ip_address])
      expect(vm_nics[1][:IpAddressAllocationMode]).to eq('MANUAL')
      expect(vm_nics[1][:NetworkConnectionIndex]).to eq('1')
    end

  end

  context "#update_storage_profile" do

    it "can update the storage profile of a VM" do
      if @new_storage_profile_name == @default_storage_profile_name
        pending("Storage profiles not available?")
      end
      original_storage_profile_name = @vm.vcloud_attributes[:StorageProfile][:name]
      @vm.update_storage_profile(@new_storage_profile_name)
      expect(original_storage_profile_name).to eq(@default_storage_profile_name)
      expect(@vm.vcloud_attributes[:StorageProfile][:name]).to eq(@new_storage_profile_name)
    end

  end

  after(:all) do
    IntegrationHelper.delete_vapps(@test_case_vapps)
  end

  def get_vm_hard_disks(fog_model_vm)
    # 'disks' Model VM method returns disks + controllers. Disks always have
    # the name 'Hard Disk {n}' where (n >= 0).
    fog_model_vm.disks.select { |disk| disk.name =~ /^Hard disk/ }
  end

  def sort_nics_based_on_network_connection_index(network_connection_list)
    # The :NetworkConnection Array is not (necessarily) ordered when it is
    # retrieved via the API.
    # Instead, they are indexed by the :NetworkConnectionIndex value, which
    # is returned by the API as a number-as-a-string (eg "0", "1")
    network_connection_list.sort do |x,y|
      Integer(x[:NetworkConnectionIndex]) <=> Integer(y[:NetworkConnectionIndex])
    end
  end

end
