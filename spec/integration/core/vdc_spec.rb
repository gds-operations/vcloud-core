require 'spec_helper'

describe Vcloud::Core::Vdc do

  let(:uuid_matcher) { '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' }

  before(:all) do
    config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
    @test_data = Vcloud::Tools::Tester::TestParameters.new(config_file)
  end

  context ".get_by_name" do

    subject { Vcloud::Core::Vdc.get_by_name(name) }

    context "when looking up a valid vDC name" do

      let(:name) { @test_data.vdc_1_name }

      it "returns a Vcloud::Core::Vdc object" do
        expect(subject).to be_instance_of(Vcloud::Core::Vdc)
      end

      it "returns a Vdc object with a valid id" do
        expect(subject.id).to match(/\A#{uuid_matcher}\Z/)
      end

      it "returns a Vdc object with our expected name" do
        expect(subject.name).to eq(name)
      end

    end

  end

end
