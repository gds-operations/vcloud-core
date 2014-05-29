require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGateway do

      before(:all) do
        config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
        @test_data = Vcloud::Tools::Tester::TestParameters.new(config_file)
      end

      let(:edge_gateway)      { EdgeGateway.get_by_name(@test_data.edge_gateway) }
      let(:edge_gateway_name) { @test_data.edge_gateway }
      let(:edge_gateway_id)   { @test_data.edge_gateway_id }
      let(:spurious_id)       { "12345678-1234-1234-1234-123456789012" }

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
          network_interface = edge_gateway.vcloud_gateway_interface_by_id(spurious_id)
          expect(network_interface).to be_nil
        end
      end

      context "when retrieving an edge gateway ID (singular) by name" do
        it "returns the an edge gateway object for that name" do
          # See `let` statement above which calls EdgeGateway::get_by_name
          expect(edge_gateway).to    be_a(Vcloud::Core::EdgeGateway)
          expect(edge_gateway.id).to eq(edge_gateway_id)
        end

        it "raise an exception if edge gateway with given ID is not found" do
          name = "this-would-never-exist"
          expect { Vcloud::Core::EdgeGateway.get_by_name(name) }.to raise_error("edgeGateway #{name} not found")
        end
      end

      context "when retrieving edge gateway IDs (plural) by name" do
        it "returns the correct ID for that name" do
          ids = Vcloud::Core::EdgeGateway.get_ids_by_name(edge_gateway_name)
          expect(ids.first).to eq(edge_gateway_id)
        end

        it "returns an empty array if edge gateway with given ID is not found" do
          name = "this-would-never-exist"
          ids = Vcloud::Core::EdgeGateway.get_ids_by_name(name)
          expect(ids).to eq([])
        end
      end

      context "when retrieving vCloud attributes" do
        it "returns the correct edge gateway for a given ID" do
          vcloud_attributes = edge_gateway.vcloud_attributes
          expect(vcloud_attributes[:href]).to include(edge_gateway_id)
        end

        it "returns the correct href for a given edge gateway" do
          href = edge_gateway.href
          expect(href).to include(edge_gateway_id)
        end

        it "returns the correct name for a given edge gateway" do
          name = edge_gateway.name
          expect(name).to eq(edge_gateway_name)
        end
      end

      context "when retrieving a gateway's interfaces" do
        let(:network_1) { @test_data.network_1 }

        it "returns an array of interface objects" do
          interfaces = edge_gateway.interfaces
          network_1_interface = interfaces.detect { |i| i.name == network_1 }

          expect(interfaces.first).to         be_a(Vcloud::Core::EdgeGatewayInterface)
          expect(network_1_interface.name).to eq(network_1)
        end
      end
    end
  end
end
