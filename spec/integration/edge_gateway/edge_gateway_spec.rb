require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGateway do
      it "should return provider networks for given edge gateway" do
        edge_gateway = EdgeGateway.get_by_name(ENV['VCLOUD_EDGE_GATEWAY'])
        gateway_interface = edge_gateway.get_gateway_interface_by_id(ENV['VCLOUD_PROVIDER_NETWORK_ID'])
        expect(gateway_interface[:Network]).not_to be_nil
        expect(gateway_interface[:Network][:href]).to include(ENV['VCLOUD_PROVIDER_NETWORK_ID'])
      end
    end
  end
end
