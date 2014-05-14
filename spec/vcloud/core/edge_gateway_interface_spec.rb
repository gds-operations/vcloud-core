require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGatewayInterface do

      before(:each) do
        @valid_ext_id = "12345678-70ac-487e-9c1e-124716764274"
        @gateway_interface_hash = {
          :Name=>"EXTERNAL_NETWORK",
          :Network=>{
            :type=>"application/vnd.vmware.admin.network+xml",
            :name=>"EXTERNAL_NETWORK",
            :href=>"https://example.com/api/admin/network/#{@valid_ext_id}"
          },
          :InterfaceType=>"uplink",
          :SubnetParticipation=>{
            :Gateway=>"192.2.0.1",
            :Netmask=>"255.255.255.0",
            :IpAddress=>"192.2.0.66"
          },
          :UseForDefaultRoute=>"true"
        }
        @interface = EdgeGatewayInterface.new(@gateway_interface_hash)
      end

      context "Instance public interface" do
        subject { EdgeGatewayInterface.new(@gateway_interface_hash) }
        it { should respond_to(:name) }
        it { should respond_to(:network_id) }
        it { should respond_to(:network_name) }
        it { should respond_to(:network_href) }
      end

      context "#initialize" do

        it "should be constructable from just a Fog vCloud GatewayInterfaceType hash" do
          obj = EdgeGatewayInterface.new(@gateway_interface_hash)
          expect(obj.class).to be(Vcloud::Core::EdgeGatewayInterface)
        end

        it "should raise an error if passed a nil value" do
          expect { EdgeGatewayInterface.new(nil) }.
            to raise_error(StandardError, /^EdgeGatewayInterface:/)
        end

        it "should raise an error if a :Name is not passed" do
          expect { EdgeGatewayInterface.new({}) }.
            to raise_error(StandardError, /^EdgeGatewayInterface:/)
        end

        it "should raise an error if a :Network is not passed" do
          expect { EdgeGatewayInterface.new({Name: 'test-interface'}) }.
            to raise_error(StandardError, /^EdgeGatewayInterface:/)
        end

      end

      context "#name" do
        it "should return the name of the interface" do
          expect(@interface.name).to eq('EXTERNAL_NETWORK')
        end
      end

      context "#network_id" do
        it "should return the id of the network the interface is connected to" do
          expect(@interface.network_id).to eq(@valid_ext_id)
        end
      end

      context "#network_name" do
        it "should return the name of the network the interface is connected to" do
          expect(@interface.network_name).to eq('EXTERNAL_NETWORK')
        end
      end

      context "#network_href" do
        it "should return the href of the network the interface is connected to" do
          expect(@interface.network_href).to eq("https://example.com/api/admin/network/#{@valid_ext_id}")
        end
      end

    end

  end

end
