require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGateway do

      required_env = {
        'VCLOUD_EDGE_GATEWAY'        => 'to name of VSE',
        'VCLOUD_PROVIDER_NETWORK_ID' => 'to ID of VSE external network',
        'VCLOUD_NETWORK1_ID'         => 'to the ID of a VSE internal network',
      }

      error = false
      required_env.each do |var,message|
        unless ENV[var]
          puts "Must set #{var} #{message}" unless ENV[var]
          error = true
        end
      end
      Kernel.exit(2) if error

      it "updates the edge gateway" do
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

        edge_gateway = EdgeGateway.get_by_name(ENV['VCLOUD_EDGE_GATEWAY'])
        edge_gateway.update_configuration(configuration)

        actual_config = edge_gateway.vcloud_attributes[:Configuration][:EdgeGatewayServiceConfiguration]
        actual_config[:FirewallService].should == configuration[:FirewallService]
        actual_config[:LoadBalancerService].should == configuration[:LoadBalancerService]
        actual_config[:NatService].should == configuration[:NatService]
      end

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
