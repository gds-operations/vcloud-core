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
    it { should respond_to(:attached_vms) }
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
      }.to raise_exception(Vcloud::Core::IndependentDisk::DiskNotFoundException)
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

  describe "#convert_size_to_bytes" do

    it "accepts integers, passing through as bytes" do
      expect(Vcloud::Core::IndependentDisk.convert_size_to_bytes(100_000_000)).to eq(100_000_000)
    end

    it "accepts suffixless strings, passing through as bytes" do
      expect(Vcloud::Core::IndependentDisk.convert_size_to_bytes('100000000')).to eq(100_000_000)
    end

    it "converts 100MB to 100_000_000 bytes" do
      expect(Vcloud::Core::IndependentDisk.convert_size_to_bytes('100MB')).to eq(100_000_000)
    end

    it "converts 10MiB to 104_857_600 bytes" do
      expect(Vcloud::Core::IndependentDisk.convert_size_to_bytes('100MiB')).to eq(104_857_600)
    end

    it "converts 10GB to 100_000_000_000 bytes" do
      expect(Vcloud::Core::IndependentDisk.convert_size_to_bytes('100GB')).to eq(100_000_000_000)
    end

    it "converts 10GiB to 100_000_000_000 bytes" do
      expect(Vcloud::Core::IndependentDisk.convert_size_to_bytes('100GiB')).to eq(107_374_182_400)
    end

    it "raises an ArgumentError if numeric component is not an integer" do
      expect{Vcloud::Core::IndependentDisk.convert_size_to_bytes('10.5GB')}.
        to raise_error(ArgumentError)
    end

    it "raises an ArgumentError if it does not understand the input" do
      expect{Vcloud::Core::IndependentDisk.convert_size_to_bytes('10wibbles')}.
        to raise_error(ArgumentError)
    end

  end

  describe "#create" do

    let(:vdc) { double(:vdc, :id => "12341234-1234-1234-1234-123412341234", :name => @vdc_name)}

    context "when there is no disk already present with that name" do

      before(:each) do
        mock_query = double(:query_runner)
        expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
        expect(mock_query).to receive(:run).with(
          'disk',
          :filter => "name==new-disk-1;vdcName==#{@vdc_name}"
        ).and_return([])
      end

      it "returns an IndependentDisk object if successful" do
        size_in_bytes = 1000_000_000
        obj = Vcloud::Core::IndependentDisk.create(vdc, "new-disk-1", size_in_bytes)
        expect(obj.class).to be(Vcloud::Core::IndependentDisk)
      end

      it "handles size parameter suffixes (MB, GB, ...)" do
        size = "100MB"
        expect(@mock_fog_interface).to receive(:post_create_disk).with(
          vdc.id, "new-disk-1", 100_000_000
        ).and_return({ :href => "/#{12341234-1234-1234-1234-123412341234}" })
        obj = Vcloud::Core::IndependentDisk.create(vdc, "new-disk-1", size)
        expect(obj.class).to be(Vcloud::Core::IndependentDisk)
      end

      it "handles size parameter given as an Integer (in bytes)" do
        size = 100_000_000_000
        expect(@mock_fog_interface).to receive(:post_create_disk).with(
          vdc.id, "new-disk-1", 100_000_000_000
        ).and_return({ :href => "/#{12341234-1234-1234-1234-123412341234}" })
        obj = Vcloud::Core::IndependentDisk.create(vdc, "new-disk-1", size)
        expect(obj.class).to be(Vcloud::Core::IndependentDisk)
      end

    end

    context "when there is a disk present in the vDC with the same name"  do

      it "raises an error" do
        mock_query = double(:query_runner)
        q_results = [ { :name => @disk_name, :href => @disk_id } ]
        expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
        expect(mock_query).to receive(:run).with(
          'disk',
          :filter => "name==#{@disk_name};vdcName==#{@vdc_name}"
        ).and_return(q_results)
        expect{ Vcloud::Core::IndependentDisk.create(vdc, @disk_name, 100_000) }.
          to raise_error(Vcloud::Core::IndependentDisk::DiskAlreadyExistsException)
      end

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

  context "#attached_vms" do

    subject { Vcloud::Core::IndependentDisk.new(@disk_id) }

    it "returns an empty list if there are no attached vms" do
      expect(@mock_fog_interface).to receive(:get_vms_disk_attached_to).
        with(subject.id).and_return({:VmReference=>[]})
      expect(subject.attached_vms).to eq([])
    end

    it "returns a list of Core::Vm objects that are attached" do
      expect(Vcloud::Core::Vapp).to receive(:get_by_child_vm_id).exactly(2).times.and_return({
        :href => "/vapp-12341234-1234-1234-1234-123412340000"
      })
      expect(@mock_fog_interface).to receive(:get_vms_disk_attached_to).
        with(subject.id).and_return({:VmReference=>[
                                    { :href => '/vm-12341234-1234-1234-1234-123412340001' },
                                    { :href => '/vm-12341234-1234-1234-1234-123412340002' },
      ]})
      vms = subject.attached_vms
      expect(vms[0].id).to eq('vm-12341234-1234-1234-1234-123412340001')
      expect(vms[1].id).to eq('vm-12341234-1234-1234-1234-123412340002')
    end

  end

  context "#destroy" do
    subject { Vcloud::Core::IndependentDisk.new(@disk_id) }

    it "deletes the independent disk entity via Fog delete_disk method" do
      expect(@mock_fog_interface).to receive(:delete_disk).
        with(subject.id)
      subject.destroy
    end

  end

end

