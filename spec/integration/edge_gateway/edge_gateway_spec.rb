require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGateway do
      context "get vcloud attributes for given gateway interface id " do
        before(:all) do
          @edge_gateway = EdgeGateway.get_by_name(ENV['VCLOUD_EDGE_GATEWAY'])
        end
        it "should return provider network" do
          gateway_interface = @edge_gateway.vcloud_gateway_interface_by_id(ENV['VCLOUD_PROVIDER_NETWORK_ID'])
          expect(gateway_interface[:Network]).not_to be_nil
          expect(gateway_interface[:Network][:href]).to include(ENV['VCLOUD_PROVIDER_NETWORK_ID'])
        end

        it "should return orgVdcNetwork" do
          gateway_interface = @edge_gateway.vcloud_gateway_interface_by_id(ENV['VCLOUD_NETWORK1_ID'])
          expect(gateway_interface[:Network]).not_to be_nil
          expect(gateway_interface[:Network][:href]).to include(ENV['VCLOUD_NETWORK1_ID'])
        end

        it "return nil if network with given id is not found" do
          gateway_interface = @edge_gateway.vcloud_gateway_interface_by_id(SecureRandom.uuid)
          expect(gateway_interface).to be_nil
        end
      end
    end
  end
end
