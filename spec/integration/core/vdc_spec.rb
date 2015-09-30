require 'spec_helper'

describe Vcloud::Core::Vdc do

  let(:uuid_matcher) { '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' }

  before(:all) do
    config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
    required_user_params = %w{ vdc_1_name }

    @test_params = Vcloud::Tools::Tester::TestSetup.new(config_file, required_user_params).test_params
  end

  describe ".get_by_name" do

    subject { Vcloud::Core::Vdc.get_by_name(name) }

    context "when looking up a valid vDC name" do

      let(:name) { @test_params.vdc_1_name }

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

    context "when looking up an invalid vDC name" do

      let(:name) { "bogus Vdc name 12p412irjof" }

      it "throws an error" do
        expect { subject }.to raise_error("vDc #{name} not found")
      end

    end

  end

  describe ".new" do

    subject { Vcloud::Core::Vdc.new(vdc_id) }

    context "when instantiating with a valid ID" do

      let(:vdc_id) { Vcloud::Core::Vdc.get_by_name(@test_params.vdc_1_name).id }

      it "returns a valid Vdc object" do
        expect(subject).to be_instance_of(Vcloud::Core::Vdc)
      end

      it "has our expected #id" do
        expect(subject.id).to eq(vdc_id)
      end

      it "has our expected #name" do
        expect(subject.name).to eq(@test_params.vdc_1_name)
      end

    end

    context "when instantiating with a valid UUID, that does not refer to a Vdc" do

      let(:vdc_id) { '12345678-1234-1234-1234-123456789012' }

      it "returns a valid Vdc object" do
        expect(subject).to be_instance_of(Vcloud::Core::Vdc)
      end

      it "has our expected #id" do
        expect(subject.id).to eq(vdc_id)
      end

      it "throws a Forbidden error when trying to access the #name of the Vdc" do
        expect { subject.name }.to raise_error(Fog::Compute::VcloudDirector::Forbidden)
      end

    end

  end

end
