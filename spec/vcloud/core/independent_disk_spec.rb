require 'spec_helper'

describe Vcloud::Core::IndependentDisk do
  before(:each) do
    @disk_id = '12345678-1234-1234-1234-112112112112'
    @disk_name = 'test-disk-1'
    @vdc_name = 'test-vdc-1'
    @mock_fog_interface = StubFogInterface.new
    allow(Vcloud::Core::Fog::ServiceInterface).to receive(:new).and_return(@mock_fog_interface)
  end

  context "Class public interface" do
    it { expect(Vcloud::Core::IndependentDisk).to respond_to(:get_by_name_and_vdc_name) }
  end

  context "Instance public interface" do
    subject { Vcloud::Core::IndependentDisk.new(@disk_id) }
    it { should respond_to(:id) }
    it { should respond_to(:vcloud_attributes) }
    it { should respond_to(:name) }
    it { should respond_to(:href) }
  end

  context "#initialize" do

    it "should be constructable from just an id reference" do
      obj = Vcloud::Core::IndependentDisk.new(@disk_id)
      expect(obj.class).to be(Vcloud::Core::IndependentDisk)
    end

    it "should store the id specified" do
      obj = Vcloud::Core::IndependentDisk.new(@disk_id)
      expect(obj.id).to eq(@disk_id)
    end

    it "should raise error if id is not in correct format" do
      bogus_id = 'foo-12314124-ede5-4d07-bad5-000000111111'
      expect{
        Vcloud::Core::IndependentDisk.new(bogus_id)
      }.to raise_error("IndependentDisk id : #{bogus_id} is not in correct format" )
    end

  end

  context "#get_by_name_and_vdc_name" do

    it "should return a Disk object if disk is found" do
      q_results = [
        { :name => @disk_name, :href => @disk_id }
      ]
      mock_query = double(:query)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with(
        'disk',
        :filter => "name==#{@disk_name};vdcName==#{@vdc_name}"
      ).and_return(q_results)
      obj = Vcloud::Core::IndependentDisk.get_by_name_and_vdc_name(@disk_name, @vdc_name)
      expect(obj.class).to be(Vcloud::Core::IndependentDisk)
    end

    it "should raise an error if no Independent Disk with that name exists" do
      q_results = [ ]
      mock_query = double(:query_runner)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with(
        'disk',
        :filter => "name==#{@disk_name};vdcName==#{@vdc_name}"
      ).and_return(q_results)
      expect {
        Vcloud::Core::IndependentDisk.get_by_name_and_vdc_name(@disk_name, @vdc_name)
      }.to raise_exception(RuntimeError)
    end

    it "should raise an error if multiple Independent Disks with " +
       "that name exists (NB: prescribes unique disk names!)" do
      q_results = [
        { :name => @disk_name, :href => @disk_id },
        { :name => @disk_name, :href => '12341234-1234-1234-1234-123456789012' },
      ]
      mock_query = double(:query)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with(
        'disk',
        :filter => "name==#{@disk_name};vdcName==#{@vdc_name}"
      ).and_return(q_results)
      expect {
        Vcloud::Core::IndependentDisk.get_by_name_and_vdc_name(@disk_name, @vdc_name)
      }.to raise_exception(RuntimeError)
    end

  end

  context "#create" do

    let(:vdc) { double(:vdc, :id => "12341234-1234-1234-1234-123412341234")}

    it "returns an IndependentDisk object if successful" do
      size_in_bytes = 1000_000_000
      obj = Vcloud::Core::IndependentDisk.create(vdc, "new-disk-1", size_in_bytes)
      expect(obj.class).to be(Vcloud::Core::IndependentDisk)
    end

  end

  context "attributes" do

    before(:each) {
      @stub_attrs = {
        :name => @disk_name,
        :href => "https://api.vcloud-director.example.com/api/disk/#{@disk_id}",
        :Link => [{
          :rel => 'up',
          :type => 'application/vnd.vmware.vcloud.vdc+xml',
          :href => 'https://api.vcloud-director.example.com/api/vdc/074aea1e-a5e9-4dd1-a028-40db8c98d237'
        }]
      }
      allow_any_instance_of(StubFogInterface).to receive(:get_disk).and_return(@stub_attrs)
      @disk = Vcloud::Core::IndependentDisk.new(@disk_id)
    }

    it { expect(@disk.name).to eq(@disk_name) }
    it { expect(@disk.id).to eq(@disk_id) }

  end

end

