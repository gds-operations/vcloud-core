require 'spec_helper'

describe Vcloud::Core::IndependentDisk do

  let(:uuid_matcher) { "[-0-9a-f]+" }

  before(:all) do
    config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
    required_user_params = [
      "vdc_1_name",
    ]

    @test_params = Vcloud::Tools::Tester::TestSetup.new(config_file, required_user_params).test_params
    @disk_name_prefix = "vcloud-core-independent-disk-tests"
    quantity_of_test_case_disks = 1
    @vdc_name = @test_params.vdc_1_name
    @vdc = Vcloud::Core::Vdc.get_by_name(@vdc_name)
    @test_disk_size = 12000000 # bytes
    @test_case_disks = IntegrationHelper.create_test_case_independent_disks(
      quantity_of_test_case_disks,
      @vdc_name,
      @test_disk_size,
      @disk_name_prefix
    )
    @test_disk = @test_case_disks.shift  # we will delete this disk in the tests
  end

  subject(:fixture_disk) { @test_disk }

  context "before the integration tests run" do

    it "ensures we have a valid IndependentDisk fixture, for subsequent tests to run against" do
      expect(fixture_disk).to be_instance_of(Vcloud::Core::IndependentDisk)
    end

  end

  describe "#vcloud_attributes" do

    it "has a :href element containing the expected Independent Disk id" do
      expect(fixture_disk.vcloud_attributes[:href].split('/').last).to eq(fixture_disk.id)
    end

  end

  describe "#id" do

    it "returns the a valid Independent Disk id" do
      expect(fixture_disk.id).to match(/^#{uuid_matcher}$/)
    end

  end

  describe "#name" do

    it "returns the name of the Independent Disk" do
      expect(fixture_disk.name).to include(@disk_name_prefix)
    end

  end

  describe "#get_by_name_and_vdc_name" do

    it "can find our fixture Independent Disk by its name & vdcName" do
      retrieved_disk = Vcloud::Core::IndependentDisk.get_by_name_and_vdc_name(
        fixture_disk.name, @vdc_name)
      expect(retrieved_disk.id).to eq(fixture_disk.id)
    end

    it "raises an error if it cannot find the named Independent Disk" do
      bogus_disk_name = "bogus-disk-name-wefoiuhwef"
      expect {
        Vcloud::Core::IndependentDisk.get_by_name_and_vdc_name(
          bogus_disk_name, @vdc_name)
      }.to raise_error(RuntimeError,
        "IndependentDisk '#{bogus_disk_name}' not found in vDC '#{@vdc_name}'"
      )
    end

  end

  describe "#create" do

    let(:disk_name) { "#{@disk_name_prefix}-instantiate-test-disk" }

    it "can create a Independent Disk" do
      new_disk = Vcloud::Core::IndependentDisk.create(
        @vdc,
        disk_name,
        10000000,
      )
      @test_case_disks << new_disk
      expect(new_disk.name).to eq(disk_name)
    end

    it "raises a DiskAlreadyExistsException if we try to create a disk with the same " +
         "name in the same vDC" do
      expect { Vcloud::Core::IndependentDisk.create(
        @vdc,
        disk_name,
        10000000)
      }.to raise_error(Vcloud::Core::IndependentDisk::DiskAlreadyExistsException)
    end

  end

  describe "#destroy" do
    it "after deletion, access to the disk is forbidden (as the API does not distinguish " +
       "not present and access-denied)" do
      fixture_disk.destroy
      expect(fixture_disk.id).to match(/^#{uuid_matcher}$/)
      expect { fixture_disk.name }.to raise_error(Fog::Compute::VcloudDirector::Forbidden)
    end
  end

  after(:all) do
    IntegrationHelper.delete_independent_disks(@test_case_disks)
  end


end
