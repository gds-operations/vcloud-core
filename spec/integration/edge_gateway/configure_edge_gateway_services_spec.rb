require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGateway do

      required_env = {
        'VCLOUD_EDGE_GATEWAY' => 'to name of VSE',
      }

      error = false
      required_env.each do |var,message|
        unless ENV[var]
          puts "Must set #{var} #{message}" unless ENV[var]
          error = true
        end
      end
      Kernel.exit(2) if error

      it "configure firewall service" do
        configuration = {
            :FirewallService =>
                {
                    :IsEnabled => "true",
                    :DefaultAction => "allow",
                    :LogDefaultAction => "false",
                    :FirewallRule =>
                        [
                            {
                                :Id => "999",
                                :IsEnabled => "false",
                                :MatchOnTranslate => "false",
                                :Description => "generated from edge_gateway_tests",
                                :Policy => "drop",
                                :Protocols => {:Tcp => "true"},
                                :Port => "3412",
                                :DestinationPortRange => "3412",
                                :DestinationIp => "internal",
                                :SourcePort => "3412",
                                :SourcePortRange => "3412",
                                :SourceIp => "internal",
                                :EnableLogging => "false"
                            }
                        ]
                }
        }
        edge_gateway = EdgeGateway.get_by_name(ENV['VCLOUD_EDGE_GATEWAY'])
        edge_gateway.update_configuration(configuration)

        actual_config = edge_gateway.vcloud_attributes[:Configuration][:EdgeGatewayServiceConfiguration]
        actual_config[:FirewallService].should == configuration[:FirewallService]
      end
    end
  end
end
