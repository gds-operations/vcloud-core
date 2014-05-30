require 'spec_helper'

describe Vcloud::Core::Vapp do

  let(:uuid_matcher) { "[-0-9a-f]+" }

  before(:all) do
    config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
    @test_data = Vcloud::Tools::Tester::TestParameters.new(config_file)
    quantity_of_test_case_vapps = 1
    @network_names = [ @test_data.network_1, @test_data.network_2 ]
    @test_case_vapps = IntegrationHelper.create_test_case_vapps(
      quantity_of_test_case_vapps,
      @test_data.vdc_1_name,
      @test_data.catalog,
      @test_data.vapp_template,
      @network_names,
      "vcloud-core-vapp-tests"
    )
    @vapp = @test_case_vapps.first
  end

  context "before the integration tests run" do

    it "ensures we have a valid vApp fixture, for subsequent tests to run against" do
      expect(@vapp).to be_instance_of(Vcloud::Core::Vapp)
    end

  end

  describe "#vcloud_attributes" do

    it "has a :href element containing the expected vApp id" do
      expect(@vapp.vcloud_attributes[:href].split('/').last).to eq(@vapp.id)
    end

  end

  describe "#id" do

    it "returns the a valid vApp id" do
      expect(@vapp.id).to match(/^vapp-#{uuid_matcher}$/)
    end

  end

  describe "#name" do

    it "returns the name of the vApp" do
      expect(@vapp.name).to match(/^vcloud-core-vapp-tests-/)
    end

  end

  describe "#vdc_id" do

    it "returns a valid uuid" do
      expect(@vapp.vdc_id).to match(/^#{uuid_matcher}$/)
    end

  end

  describe "#networks" do

    it "returns hashes for each network, plus the 'none' placeholder network" do
      network_output = @vapp.networks
      # The API return a 'placeholder' network hash as well as
      # any configured networks, for any VMs that have disconnected interfaces.
      # This has the :ovf_name of 'none'. So, we expect our @network_names, plus 'none'.
      #
      expect(network_output.map { |network| network[:ovf_name] }).
        to match_array(@network_names + ["none"])
    end

  end

  describe "#power_on" do

    it "powers up a powered down Vapp" do
      expect(Integer(@vapp.vcloud_attributes[:status])).to eq(Vcloud::Core::Vapp::STATUS::POWERED_OFF)
      expect(@vapp.power_on).to be_true
      expect(Integer(@vapp.vcloud_attributes[:status])).to eq(Vcloud::Core::Vapp::STATUS::RUNNING)
    end

  end

  describe ".get_by_name" do

    it "can find our fixture vApp by its name" do
      retrieved_vapp = Vcloud::Core::Vapp.get_by_name(@vapp.name)
      expect(retrieved_vapp.id).to eq(@vapp.id)
    end

    it "raises an error if it cannot find the named vApp" do
      bogus_vapp_name = "bogus-vapp-name-wefoiuhwef"
      expect {
        Vcloud::Core::Vapp.get_by_name(bogus_vapp_name)
      }.to raise_error("vApp #{bogus_vapp_name} not found")
    end

  end

  describe ".instantiate" do

    let(:vapp_template) {
      Vcloud::Core::VappTemplate.get(@test_data.vapp_template, @test_data.catalog)
    }

    it "can create a vApp with no networks assigned" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      new_vapp = Vcloud::Core::Vapp.instantiate(
        vapp_name,
        [],
        vapp_template.id,
        @test_data.vdc_1_name
      )
      @test_case_vapps << new_vapp
      expect(new_vapp.name).to eq(vapp_name)
      expect(sanitize_networks_output(new_vapp.networks).size).to eq(0)
    end

    it "can create a vApp with one networks assigned" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      new_vapp = Vcloud::Core::Vapp.instantiate(
        vapp_name,
        [ @test_data.network_1 ],
        vapp_template.id,
        @test_data.vdc_1_name
      )
      @test_case_vapps << new_vapp
      expect(new_vapp.name).to eq(vapp_name)
      expect(sanitize_networks_output(new_vapp.networks).size).to eq(1)
    end

    it "can create a vApp with two networks assigned" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      new_vapp = Vcloud::Core::Vapp.instantiate(
        vapp_name,
        [ @test_data.network_1, @test_data.network_2 ],
        vapp_template.id,
        @test_data.vdc_1_name
      )
      @test_case_vapps << new_vapp
      expect(new_vapp.name).to eq(vapp_name)
      expect(sanitize_networks_output(new_vapp.networks).size).to eq(2)
    end

    it "raises a Fog error if the vAppTemplate id refers to a non-existent template" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      expect {
        Vcloud::Core::Vapp.instantiate(
          vapp_name,
          [],
          "vAppTemplate-12345678-1234-1234-1234-1234567890ab",
          @test_data.vdc_1_name
        )
      }.to raise_error(Fog::Compute::VcloudDirector::Forbidden, "Access is forbidden")
    end

    it "raises a Fog error if the vAppTemplate id is invalid" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      expect {
        Vcloud::Core::Vapp.instantiate(
          vapp_name,
          [],
          "invalid-vapp-template-id",
          @test_data.vdc_1_name
        )
      }.to raise_error(Fog::Compute::VcloudDirector::Forbidden, "This operation is denied.")
    end

    it "raises a Fog error if the vAppTemplate id is nil" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      expect {
        Vcloud::Core::Vapp.instantiate(
          vapp_name,
          [],
          nil,
          @test_data.vdc_1_name
        )
      }.to raise_error(Fog::Compute::VcloudDirector::BadRequest)
    end

    it "raises an error if we try to instantiate into a non-existent vDC" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      bogus_vdc_name = "NonExistentVdc asnfiuqwf"
      expect {
        Vcloud::Core::Vapp.instantiate(
          vapp_name,
          [],
          vapp_template.id,
          bogus_vdc_name
        )
      }.to raise_error("vdc #{bogus_vdc_name} cannot be found")
    end

    it "raises an error if the vDC name is nil" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      expect {
        Vcloud::Core::Vapp.instantiate(
          vapp_name,
          [],
          vapp_template.id,
          nil
        )
      }.to raise_error("vdc  cannot be found")
    end

    it "skips bogus network names specified in the network_names array" do
      vapp_name = "vcloud-core-vapp-instantiate-tests-#{Time.new.to_i}"
      new_vapp = Vcloud::Core::Vapp.instantiate(
        vapp_name,
        ['bogus-network-name-ijwioewiwego', 'bogus-network-name-asofijqweof'],
        vapp_template.id,
        @test_data.vdc_1_name
      )
      @test_case_vapps << new_vapp
      expect(new_vapp.networks).to eq({
        :ovf_name => "none",
        :"ovf:Description" =>
          "This is a special place-holder used for disconnected network interfaces."
      })
    end

  end

  after(:all) do
    IntegrationHelper.delete_vapps(@test_case_vapps)
  end

  def sanitize_networks_output(networks_output)
    if networks_output.is_a?(Hash)
      # Fog currently has a bug (https://github.com/fog/fog/issues/2927) that
      # means the output from Vapp#networks can be a hash or array.
      # Work around this by converting to a single element Array.
      networks_output = [ networks_output ]
    end
    new_output = []
    networks_output.each do |network_hash|
      new_output << network_hash unless network_hash[:ovf_name] == 'none'
    end
    new_output
  end

end
