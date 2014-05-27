require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGateway do

      before(:all) do
        config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
        @test_data = Vcloud::Tools::Tester::TestParameters.new(config_file)
      end

      let(:edge_gateway) { EdgeGateway.get_by_name(@test_data.edge_gateway) }

      context "when updating the edge gateway" do
        before(:each) do
          IntegrationHelper.reset_edge_gateway(edge_gateway)
        end

        it "updates as expected" do
          configuration = {
              :FirewallService =>
                  {
                      :IsEnabled        => "true",
                      :FirewallRule     => [],
                      :DefaultAction    => "drop",
                      :LogDefaultAction => "false",
                  },
              :LoadBalancerService =>
                  {
                      :IsEnabled      => "true",
                      :Pool           => [],
                      :VirtualServer  => [],
                  },
              :NatService =>
                  {
                      :IsEnabled  => "true",
                      :NatRule    => [],
                  },
          }

          edge_gateway.update_configuration(configuration)

          actual_config = edge_gateway.vcloud_attributes[:Configuration][:EdgeGatewayServiceConfiguration]

          expect(actual_config[:FirewallService]).to      eq(configuration[:FirewallService])
          expect(actual_config[:LoadBalancerService]).to  eq(configuration[:LoadBalancerService])
          expect(actual_config[:NatService]).to           eq(configuration[:NatService])
        end
      end

      context "get vCloud attributes for given gateway interface ID" do
        let(:provider_network_id)  { @test_data.provider_network_id }
        let(:network_1_id)         { @test_data.network_1_id }

        it "returns a provider network" do
          network_interface = edge_gateway.vcloud_gateway_interface_by_id(provider_network_id)
          expect(network_interface[:Network]).not_to be_nil
          expect(network_interface[:Network][:href]).to include(provider_network_id)
        end

        it "returns an orgVdcNetwork" do
          network_interface = edge_gateway.vcloud_gateway_interface_by_id(network_1_id)
          expect(network_interface[:Network]).not_to be_nil
          expect(network_interface[:Network][:href]).to include(network_1_id)
        end

        it "returns nil if network with given ID is not found" do
          network_interface = edge_gateway.vcloud_gateway_interface_by_id(SecureRandom.uuid)
          expect(network_interface).to be_nil
        end
      end
    end
  end
end
