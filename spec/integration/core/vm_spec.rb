require 'spec_helper'

describe Vcloud::Core::Vm do

  before(:all) do
    config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
    test_data = Vcloud::Tools::Tester::TestParameters.new(config_file)
    @vdc_name = test_data.vdc_1_name
    @catalog_name = test_data.catalog
    @vapp_template_name = test_data.vapp_template
    @network_names = [ test_data.network_1, test_data.network_2 ]
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
  end

  context "#update_cpu_count" do
  end

  context "#update_metadata" do
  end

  context "#add_extra_disks" do
  end

  context "#configure_network_interfaces" do
  end

  context "#configure_guest_customization_section" do
  end

  after(:all) do
    IntegrationHelper.delete_vapps(@test_case_vapps)
  end

end
