require 'spec_helper'

describe Vcloud::Core::Vapp do

  let(:uuid_matcher) { "[-0-9a-f]+" }

  before(:all) do
    config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
    test_data = Vcloud::Tools::Tester::TestParameters.new(config_file)
    @vdc_name = test_data.vdc_1_name
    @catalog_name = test_data.catalog
    @vapp_template_name = test_data.vapp_template
    @network_names = [ test_data.network_1, test_data.network_2 ]
    @test_case_vapps = IntegrationHelper.create_test_case_vapps(
      1, @vdc_name, @catalog_name, @vapp_template_name, @network_names, "vcloud-core-vapp-tests")
    @vapp = @test_case_vapps.first
  end

  context "ensure our fixtures are as expected" do

    it "ensures we have a test case vApp" do
      expect(@vapp).to be_instance_of(Vcloud::Core::Vapp)
    end

  end

  context "#vcloud_attributes" do

    it "has a :href element containing the expected vApp id" do
      expect(@vapp.vcloud_attributes[:href].split('/').last).to eq(@vapp.id)
    end

  end

  context "#id" do

    it "returns the a valid vApp id" do
      expect(@vapp.id).to match(/^vapp-#{uuid_matcher}$/)
    end

  end

  context "#name" do

    it "returns the name of the vApp" do
      expect(@vapp.name).to match(/^vcloud-core-vapp-tests-/)
    end

  end

  context "#vdc_id" do

    it "returns a valid uuid" do
      expect(@vapp.vdc_id).to match(/^#{uuid_matcher}$/)
    end

  end

  after(:all) do
    IntegrationHelper.delete_vapps(@test_case_vapps)
  end

end
