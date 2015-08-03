require 'spec_helper'

describe Vcloud::Core::Vapp do
  before(:each) do
    @vapp_id = 'vapp-12345678-1234-1234-1234-000000111111'
    @mock_fog_interface = StubFogInterface.new
    allow(Vcloud::Core::Fog::ServiceInterface).to receive(:new).and_return(@mock_fog_interface)
  end

  context "Class public interface" do
    it { expect(Vcloud::Core::Vapp).to respond_to(:instantiate) }
    it { expect(Vcloud::Core::Vapp).to respond_to(:get_by_name) }
    it { expect(Vcloud::Core::Vapp).to respond_to(:get_metadata) }
  end

  context "Instance public interface" do
    subject { Vcloud::Core::Vapp.new(@vapp_id) }
    it { should respond_to(:id) }
    it { should respond_to(:vcloud_attributes) }
    it { should respond_to(:name) }
    it { should respond_to(:href) }
    it { should respond_to(:vdc_id) }
    it { should respond_to(:vms) }
    it { should respond_to(:networks) }
    it { should respond_to(:power_on) }
  end

  context "#initialize" do

    it "should be constructable from just an id reference" do
      obj = Vcloud::Core::Vapp.new(@vapp_id)
      expect(obj.class).to be(Vcloud::Core::Vapp)
    end

    it "should store the id specified" do
      obj = Vcloud::Core::Vapp.new(@vapp_id)
      expect(obj.id).to eq(@vapp_id)
    end

    it "should raise error if id is not in correct format" do
      bogus_id = '12314124-ede5-4d07-bad5-000000111111'
      expect{ Vcloud::Core::Vapp.new(bogus_id) }.to raise_error("vapp id : #{bogus_id} is not in correct format" )
    end

  end

  context "#get_by_name" do

    it "should return a Vcloud::Core::Vapp object if name exists" do
      q_results = [
        { :name => 'vapp-test-1', :href => @vapp_id }
      ]
      mock_query = double(:query)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with('vApp', :filter => "name==vapp-test-1").and_return(q_results)
      obj = Vcloud::Core::Vapp.get_by_name('vapp-test-1')
      expect(obj.class).to be(Vcloud::Core::Vapp)
    end

    it "should raise an error if no vApp with that name exists" do
      q_results = [ ]
      mock_query = double(:query_runner)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with('vApp', :filter => "name==vapp-test-1").and_return(q_results)
      expect{ Vcloud::Core::Vapp.get_by_name('vapp-test-1') }.to raise_exception(RuntimeError)
    end

    it "should raise an error if multiple vApps with that name exists (NB: prescribes unique vApp names!)" do
      q_results = [
        { :name => 'vapp-test-1', :href => @vapp_id },
        { :name => 'vapp-test-1', :href => '/bogus' },
      ]
      mock_query = double(:query)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with('vApp', :filter => "name==vapp-test-1").and_return(q_results)
      expect{ Vcloud::Core::Vapp.get_by_name('vapp-test-1') }.to raise_exception(RuntimeError)
    end

  end

  context "attributes" do
    before(:each) {
      @stub_attrs = {
      :name => 'Webserver vapp-1',
      :href => "https://api.vcd.portal.skyscapecloud.com/api/vApp/#{@vapp_id}",
      :Link => [{
        :rel => 'up',
        :type => 'application/vnd.vmware.vcloud.vdc+xml',
        :href => 'https://api.vcloud-director.example.com/api/vdc/074aea1e-a5e9-4dd1-a028-40db8c98d237'
      }],
        :Children => {:Vm => [{:href => '/vm-123aea1e-a5e9-4dd1-a028-40db8c98d237'}]}
    }
    allow_any_instance_of(StubFogInterface).to receive(:get_vapp).and_return(@stub_attrs)
    @vapp = Vcloud::Core::Vapp.new(@vapp_id)
    }
    it { expect(@vapp.name).to eq('Webserver vapp-1') }

    context "id" do
      it "should extract id correctly" do
        expect(@vapp.id).to eq(@vapp_id)
      end
    end

    context "vapp should have parent vdc" do
      it "should load parent vdc id from fog attributes" do
        expect(@vapp.vdc_id).to eq('074aea1e-a5e9-4dd1-a028-40db8c98d237')
      end

      it "should raise error if vapp without parent vdc found" do
        @stub_attrs[:Link] = []
        expect { @vapp.vdc_id }.to raise_error('a vapp without parent vdc found')
      end
    end

    it "should return vms" do
      expect(@vapp.vms.count).to eq(1)
      expect(@vapp.vms.first[:href]).to eq('/vm-123aea1e-a5e9-4dd1-a028-40db8c98d237')
    end
  end

  context "power on" do
    context "successful power on" do
      before(:each) do
        @fog_vapp_body = {
          :name => "Webserver vapp-1",
          :href => "https://api.vcloud-director.example.com/api/vApp/vapp-63d3be58-2d5c-477d-8410-267e7c3c4a02",
          :Link => [{
          :rel => "up",
          :type => "application/vnd.vmware.vcloud.vdc+xml",
          :href => "https://api.vcloud-director.example.com/api/vdc/074aea1e-a5e9-4dd1-a028-40db8c98d237"
        }]
        }
      end

      it "should power on a vapp that is not powered on" do
        vapp = Vcloud::Core::Vapp.new(@vapp_id)
        expect(@mock_fog_interface).to receive(:get_vapp).twice().and_return(
          {:status => Vcloud::Core::Vapp::STATUS::POWERED_OFF},
          {:status => Vcloud::Core::Vapp::STATUS::RUNNING}
        )
        expect(@mock_fog_interface).to receive(:power_on_vapp).with(vapp.id)
        state = vapp.power_on
        expect(state).to be_true
      end

      it "should not power on a vapp that is already powered on, but should return true" do
        vapp = Vcloud::Core::Vapp.new(@vapp_id)
        expect(@mock_fog_interface).to receive(:get_vapp).and_return(
          {:status => Vcloud::Core::Vapp::STATUS::RUNNING}
        )
        expect(@mock_fog_interface).not_to receive(:power_on_vapp)
        state = vapp.power_on
        expect(state).to be_true
      end
    end

  context "power off" do
    context "successful power off" do
      before(:each) do
        @fog_vapp_body = {
          :name => "Webserver vapp-1",
          :href => "https://api.vcloud-director.example.com/api/vApp/vapp-63d3be58-2d5c-477d-8410-267e7c3c4a02",
          :Link => [{
          :rel  => "stopped",
          :type => "application/vnd.vmware.vcloud.vdc+xml",
          :href => "https://api.vcloud-director.example.com/api/vdc/074aea1e-a5e9-4dd1-a028-40db8c98d237"
          }]
        }
      end

      it "should power off a vapp that is powered on" do
        vapp = Vcloud::Core::Vapp.new(@vapp_id)
        expect(@mock_fog_interface).to receive(:get_vapp).twice().and_return(
          {:status => Vcloud::Core::Vapp::STATUS::RUNNING},
          {:status => Vcloud::Core::Vapp::STATUS::POWERED_OFF}
        )
        expect(@mock_fog_interface).to receive(:power_off_vapp).with(vapp.id)
        state = vapp.power_off
        expect(state).to be_true
      end

      it "should not try to power off a vapp that is already stopped" do
        vapp = Vcloud::Core::Vapp.new(@vapp_id)
        expect(@mock_fog_interface).to receive(:get_vapp).and_return(
          {:status => Vcloud::Core::Vapp::STATUS::POWERED_OFF}
        )
        expect(@mock_fog_interface).not_to receive(:power_off_vapp)
        state = vapp.power_off
        expect(state).to be_true
      end
    end

  end

  context "#get_by_name_and_vdc_name" do

    it "should return nil if fog returns nil" do
      allow_any_instance_of(StubFogInterface).to receive(:get_vapp_by_name_and_vdc_name)
      .with('vapp_name', 'vdc_name').and_return(nil)
      expect(Vcloud::Core::Vapp.get_by_name_and_vdc_name('vapp_name', 'vdc_name')).to be_nil
    end

    it "should return vapp instance if found" do
      vcloud_attr_vapp = { :href => "/#{@vapp_id}" }
      allow_any_instance_of(StubFogInterface).to receive(:get_vapp_by_name_and_vdc_name)
      .with('vapp_name', 'vdc_name').and_return(vcloud_attr_vapp)
      expect(Vcloud::Core::Vapp.get_by_name_and_vdc_name('vapp_name', 'vdc_name').class).to eq(Vcloud::Core::Vapp)
    end
  end

  context "#get_by_child_vm_id" do

    it "should raise an ArgumentError if an invalid VM id is supplied" do
      vm_id = 'vapp-12341234-1234-1234-1234-123412341234'
      expect {Vcloud::Core::Vapp.get_by_child_vm_id(vm_id)}.to raise_error(ArgumentError)
    end

    it "should return a vApp object if we supply an existing VM id" do
      vm_id = "vm-12341234-1234-1234-1234-123412340001"
      vapp_id = "vapp-12341234-1234-1234-1234-123412349999"
      expect(@mock_fog_interface).to receive(:get_vapp).with(vm_id).and_return({
        :Link => [
          { :rel => 'down',
            :type => "application/vnd.vmware.vcloud.metadata+xml",
            :href => "/api/vApp/#{vm_id}/metadata"
      },
        { :rel => 'up',
          :type => "application/vnd.vmware.vcloud.vApp+xml",
          :href => "/api/vApp/#{vapp_id}"
      }
      ]
      })
      obj = Vcloud::Core::Vapp.get_by_child_vm_id(vm_id)
      expect(obj.id).to eq(vapp_id)
    end
  end
  end
end

