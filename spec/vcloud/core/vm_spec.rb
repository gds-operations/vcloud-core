require 'spec_helper'

module Vcloud
  module Core
    describe Vm do

      before(:each) do
        @vm_id = 'vm-1234'
        @vapp_id = 'vapp-4321'
        @vapp_name = 'test-vapp-1'
        @vm_name = 'test-vm-1'
        @data_dir = File.join(File.dirname(__FILE__), "/data")
        @mock_vm_memory_size = 1024
        @mock_metadata = {
            :foo => "bar",
            :false_thing => false,
            :true_thing => true,
            :number => 53,
            :zero => 0,
        }
        @mock_vm_cpu_count = 1
        @fog_interface = StubFogInterface.new
        @mock_vapp = double(:vappm, :name => @vapp_name, :id => @vapp_id)
        Vcloud::Fog::ServiceInterface.stub(:new).and_return(@fog_interface)
        @fog_interface.stub(:get_vapp).with(@vm_id).and_return({
            :name => "#{@vm_name}",
            :href => "vm-href/#{@vm_id}",
            :'ovf:VirtualHardwareSection' => {
                :'ovf:Item' => [
                    {
                        :'rasd:ResourceType' => '4',
                        :'rasd:VirtualQuantity' => "#{@mock_vm_memory_size}",
                    },
                    {
                        :'rasd:ResourceType' => '3',
                        :'rasd:VirtualQuantity' => "#{@mock_vm_cpu_count}",
                    }
                ]
            }
        })
        @vm =  Vm.new(@vm_id, @mock_vapp)
      end

      context "Class public interface" do
      end

      context "Instance public interface" do
        subject { Vm.new(@vm_id, @mock_vapp) }
        it { should respond_to(:id) }
        it { should respond_to(:vcloud_attributes) }
        it { should respond_to(:name) }
        it { should respond_to(:href) }
        it { should respond_to(:vapp_name) }
        it { should respond_to(:update_name) }
        it { should respond_to(:update_cpu_count) }
        it { should respond_to(:update_metadata) }
        it { should respond_to(:update_storage_profile) }
        it { should respond_to(:add_extra_disks) }
        it { should respond_to(:configure_network_interfaces) }
        it { should respond_to(:configure_guest_customization_section) }
        it { should respond_to(:generate_preamble) }
      end

      context "#initialize" do

        it "should be constructable from just an id reference & Vapp object" do
          obj = Vm.new(@vm_id, @mock_vapp)
          expect(obj.class).to be(Vcloud::Core::Vm)
        end

        it "should store the id specified" do
          obj = Vm.new(@vm_id, @mock_vapp)
          expect(obj.id).to eq(@vm_id)
        end

        it "should raise error if id is not in correct format" do
          bogus_id = '12314124-ede5-4d07-bad5-000000111111'
          expect{ Vm.new(bogus_id, @mock_vapp) }.to raise_error("vm id : #{bogus_id} is not in correct format" )
        end

      end

      context "update memory in VM" do
        it "should not allow memory size < 64MB" do
          @fog_interface.should_not_receive(:put_memory)
          @vm.update_memory_size_in_mb(63)
        end
        it "should not update memory if is size has not changed" do
          @fog_interface.should_not_receive(:put_memory)
          @vm.update_memory_size_in_mb(@mock_vm_memory_size)
        end
        it "should gracefully handle a nil memory size" do
          @fog_interface.should_not_receive(:put_memory)
          @vm.update_memory_size_in_mb(nil)
        end
        it "should set memory size 64MB" do
          @fog_interface.should_receive(:put_memory).with(@vm_id, 64)
          @vm.update_memory_size_in_mb(64)
        end
        it "should set memory size 4096MB" do
          @fog_interface.should_receive(:put_memory).with(@vm_id, 4096)
          @vm.update_memory_size_in_mb(4096)
        end
      end

      context "update the number of cpus in vm" do
        it "should gracefully handle nil cpu count" do
          @fog_interface.should_not_receive(:put_cpu)
          @vm.update_cpu_count(nil)
        end
        it "should not update cpu if is count has not changed" do
          @fog_interface.should_not_receive(:put_cpu)
          @vm.update_cpu_count(@mock_vm_cpu_count)
        end
        it "should not allow a zero cpu count" do
          @fog_interface.should_not_receive(:put_cpu)
          @vm.update_cpu_count(0)
        end
        it "should update cpu count in input is ok" do
          @fog_interface.should_receive(:put_cpu).with(@vm_id, 2)
          @vm.update_cpu_count(2)
        end
      end

      context '#configure_guest_customization_section' do

        it "should handle complete configuration" do
          name = 'test-vm'
          bootstrap_config = {
            script_path: 'hello_world.erb',
            script_post_processor: 'remove_hello.rb',
            vars: { bob: 'hello', mary: 'hello' },
          }
          extra_disks = []
          @vm.should_receive(:generate_preamble).
            with('hello_world.erb', 'remove_hello.rb', {
              bob: "hello",
              mary: "hello",
              extra_disks: [] }).
            and_return('RETURNED_PREAMBLE')
          @fog_interface.should_receive(:put_guest_customization_section).
            with(@vm_id, 'test-vm', 'RETURNED_PREAMBLE')
          @vm.configure_guest_customization_section(name, bootstrap_config, extra_disks)
        end

        it "should handle nil configuration" do
          name = 'test-vm'
          bootstrap_config = nil
          extra_disks = nil
          @vm.should_not_receive(:generate_preamble)
          @fog_interface.should_receive(:put_guest_customization_section).
            with(@vm_id, 'test-vm', '')
          @vm.configure_guest_customization_section(name, bootstrap_config, extra_disks)
        end

        it "should handle empty configuration" do
          name = 'test-vm'
          bootstrap_config = {}
          extra_disks = nil
          @vm.should_not_receive(:generate_preamble)
          @fog_interface.should_receive(:put_guest_customization_section).
            with(@vm_id, 'test-vm', '')
          @vm.configure_guest_customization_section(name, bootstrap_config, extra_disks)
        end

        it "should handle bootstrap vars being missing" do
          name = 'test-vm'
          bootstrap_config = {
            script_path: 'hello_world.erb',
            script_post_processor: 'remove_hello.rb',
          }
          extra_disks = []
          @vm.should_receive(:generate_preamble).
            with('hello_world.erb', 'remove_hello.rb', { extra_disks: [] }).
            and_return('RETURNED_PREAMBLE')
          @fog_interface.should_receive(:put_guest_customization_section).
            with(@vm_id, 'test-vm', 'RETURNED_PREAMBLE')
          @vm.configure_guest_customization_section(name, bootstrap_config, extra_disks)
        end

      end

      context '#generate_preamble' do
        it "should interpolate vars hash, ENV, and vapp_name into template" do
          vars = {
            :message => 'hello world',
            :array_test => [ 'foo', 'bar' ],
          }
          stub_const('ENV', {'TEST_INTERPOLATED_ENVVAR' => 'test_interpolated_env'})
          erbfile = "#{@data_dir}/basic_preamble_test.erb"
          expected_output = File.read("#{erbfile}.OUT")
          @vm.generate_preamble(erbfile, nil, vars).should == expected_output
        end

        it "passes the output of ERB through an optional post-processor tool" do
          # we use 'wc' as post processor since it will give us the character
          # count in the file, which we can easily match on, and is common
          # across most OSes.
          vars = {}
          erbfile = "#{@data_dir}/preamble_post_processor_test_input.erb"
          characters_in_file = File.read(erbfile).size
          expect(@vm.generate_preamble(erbfile, '/usr/bin/wc', vars)).
            to match(/^\s+\d+\s+\d+\s+#{characters_in_file}\s/)
        end
      end

      context "update metadata" do
        it "should handle empty metadata hash" do
          @fog_interface.should_not_receive(:put_vapp_metadata_value)
          @vm.update_metadata(nil)
        end
        it "should handle metadata of multiple types" do
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vm_id, :foo, 'bar')
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vm_id, :false_thing, false)
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vm_id, :true_thing, true)
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vm_id, :number, 53)
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vm_id, :zero, 0)
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vapp_id, :foo, 'bar')
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vapp_id, :false_thing, false)
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vapp_id, :true_thing, true)
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vapp_id, :number, 53)
          @fog_interface.should_receive(:put_vapp_metadata_value).with(@vapp_id, :zero, 0)
          @vm.update_metadata(@mock_metadata)
        end
      end

      context "configure vm network interfaces" do
        it "should configure single nic without an IP" do
          network_config = [{:name => 'Default'}]
          @fog_interface.should_receive(:put_network_connection_system_section_vapp).with(@vm_id, {
              :PrimaryNetworkConnectionIndex => 0,
              :NetworkConnection => [
                  {
                      :network => 'Default',
                      :needsCustomization => true,
                      :NetworkConnectionIndex => 0,
                      :IsConnected => true,
                      :IpAddressAllocationMode => "DHCP"
                  }
              ]})
          @vm.configure_network_interfaces(network_config)
        end

        it "should configure nic from pool" do
          network_config = [{:name => 'Default', :allocation_mode => 'pool'}]
          @fog_interface.should_receive(:put_network_connection_system_section_vapp).with(@vm_id, {
              :PrimaryNetworkConnectionIndex => 0,
              :NetworkConnection => [
                  {
                      :network => 'Default',
                      :needsCustomization => true,
                      :NetworkConnectionIndex => 0,
                      :IsConnected => true,
                      :IpAddressAllocationMode => "POOL"
                  }
              ]})
          @vm.configure_network_interfaces(network_config)
        end

        it "should prefer configuring nic with static address" do
          network_config = [{:name => 'Default', :allocation_mode => 'dhcp', :ip_address => '192.168.1.1'}]
          @fog_interface.should_receive(:put_network_connection_system_section_vapp).with(@vm_id, {
              :PrimaryNetworkConnectionIndex => 0,
              :NetworkConnection => [
                  {
                      :network => 'Default',
                      :needsCustomization => true,
                      :NetworkConnectionIndex => 0,
                      :IsConnected => true,
                      :IpAddress => "192.168.1.1",
                      :IpAddressAllocationMode => "MANUAL"
                  }
              ]})
          @vm.configure_network_interfaces(network_config)
        end

        it "should configure single nic" do
          network_config = [{:name => 'Default', :ip_address => '192.168.1.1'}]
          @fog_interface.should_receive(:put_network_connection_system_section_vapp).with(@vm_id, {
              :PrimaryNetworkConnectionIndex => 0,
              :NetworkConnection => [
                  {
                      :network => 'Default',
                      :needsCustomization => true,
                      :NetworkConnectionIndex => 0,
                      :IsConnected => true,
                      :IpAddress => "192.168.1.1",
                      :IpAddressAllocationMode => "MANUAL"
                  }
              ]})
          @vm.configure_network_interfaces(network_config)
        end

        it "should configure multiple nics" do
          network_config = [
              {:name => 'Default', :ip_address => '192.168.1.1'},
              {:name => 'Monitoring', :ip_address => '192.168.2.1'}
          ]

          @fog_interface.should_receive(:put_network_connection_system_section_vapp).with(@vm_id, {
              :PrimaryNetworkConnectionIndex => 0,
              :NetworkConnection => [
                  {
                      :network => 'Default',
                      :needsCustomization => true,
                      :NetworkConnectionIndex => 0,
                      :IsConnected => true,
                      :IpAddress => "192.168.1.1",
                      :IpAddressAllocationMode => "MANUAL"
                  },
                  {
                      :network => 'Monitoring',
                      :needsCustomization => true,
                      :NetworkConnectionIndex => 1,
                      :IsConnected => true,
                      :IpAddress => "192.168.2.1",
                      :IpAddressAllocationMode => "MANUAL"
                  },
              ]})
          @vm.configure_network_interfaces(network_config)
        end

        it "should configure no nics" do
          network_config = nil
          @fog_interface.should_not_receive(:put_network_connection_system_section_vapp)
          @vm.configure_network_interfaces(network_config)
        end

      end

      context "update storage profiles" do
        it "should update the storage profile" do
          storage_profile = 'storage_profile_name'
          vdc_results = [
            { :vdcName => 'vdc-test-1' }
          ]
          mock_vdc_query = double(:query_runner)

          storage_profile_results = [
            { :href => 'test-href' }
          ]
          mock_sp_query = double(:query_runner)

          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_vdc_query)
          mock_vdc_query.should_receive(:run).with('vApp', :filter => "name==#{@vapp_name}").and_return(vdc_results)
          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_sp_query)
          mock_sp_query.should_receive(:run).
            with('orgVdcStorageProfile', :filter => "name==storage_profile_name;vdcName==vdc-test-1").
            and_return(storage_profile_results)

          generated_storage_profile = { name: 'storage_profile_name', href: 'test-href' }
          @fog_interface.should_receive(:put_vm).with(@vm_id, @vm_name, { :StorageProfile => generated_storage_profile} ).and_return(true)
          @vm.update_storage_profile(storage_profile).should == true
        end

        it "should raise an error if storage profile is not found" do
          storage_profile = 'storage_profile_name'
          vdc_results = [
            { :vdcName => 'vdc-test-1' }
          ]
          mock_vdc_query = double(:query_runner)

          storage_profile_results = []
          mock_sp_query = double(:query_runner)

          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_vdc_query)
          mock_vdc_query.should_receive(:run).with('vApp', :filter => "name==#{@vapp_name}").and_return(vdc_results)
          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_sp_query)
          mock_sp_query.should_receive(:run).
            with('orgVdcStorageProfile', :filter => "name==storage_profile_name;vdcName==vdc-test-1").
            and_return(storage_profile_results)

          expect{ @vm.update_storage_profile(storage_profile) }.to raise_error("storage profile not found" )
        end

        it "should raise an error if storage profile id is in unexpected format" do
          storage_profile = 'storage_profile_name'
          vdc_results = [
            { :vdcName => 'vdc-test-1' }
          ]
          mock_vdc_query = double(:query_runner)

          storage_profile_results = [ { :id => 'test-href'  }]
          mock_sp_query = double(:query_runner)

          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_vdc_query)
          mock_vdc_query.should_receive(:run).with('vApp', :filter => "name==#{@vapp_name}").and_return(vdc_results)
          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_sp_query)
          mock_sp_query.should_receive(:run).
            with('orgVdcStorageProfile', :filter => "name==storage_profile_name;vdcName==vdc-test-1").
            and_return(storage_profile_results)

          expect{ @vm.update_storage_profile(storage_profile) }.to raise_error("storage profile not found" )
        end

      end

    end
  end
end

