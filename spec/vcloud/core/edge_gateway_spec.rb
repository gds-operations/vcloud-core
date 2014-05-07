require 'spec_helper'

module Vcloud
  module Core
    describe EdgeGateway do

      before(:each) do
        @edgegw_id = '12345678-1234-1234-1234-000000111454'
        @mock_fog_interface = StubFogInterface.new
        Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
      end

      context "Class public interface" do
        it { EdgeGateway.should respond_to(:get_ids_by_name) }
        it { EdgeGateway.should respond_to(:get_by_name) }
      end

      context "Instance public interface" do
        subject { EdgeGateway.new(@edgegw_id) }
        it { should respond_to(:id) }
        it { should respond_to(:name) }
        it { should respond_to(:href) }
        it { should respond_to(:vcloud_gateway_interface_by_id) }
      end

      context "#initialize" do

        it "should be constructable from just an id reference" do
          obj = EdgeGateway.new(@edgegw_id)
          expect(obj.class).to be(Vcloud::Core::EdgeGateway)
        end

        it "should store the id specified" do
          obj = EdgeGateway.new(@edgegw_id)
          expect(obj.id).to eq(@edgegw_id)
        end

        it "should raise error if id is not in correct format" do
          bogus_id = '123123-bogus-id-123445'
          expect{ EdgeGateway.new(bogus_id) }.to raise_error("EdgeGateway id : #{bogus_id} is not in correct format" )
        end

      end

      context "#get_by_name" do

        it "should return a EdgeGateway object if name exists" do
          q_results = [
            { :name => 'edgegw-test-1', :href => "/#{@edgegw_id}" }
          ]
          mock_query = double(:query_runner)
          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_query)
          mock_query.should_receive(:run).with('edgeGateway', :filter => "name==edgegw-test-1").and_return(q_results)
          @obj = EdgeGateway.get_by_name('edgegw-test-1')
          expect(@obj.class).to be(Vcloud::Core::EdgeGateway)
        end

        it "should return an object with the correct id if name exists" do
          q_results = [
            { :name => 'edgegw-test-1', :href => "/#{@edgegw_id}" }
          ]
          mock_query = double(:query_runner)
          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_query)
          mock_query.should_receive(:run).with('edgeGateway', :filter => "name==edgegw-test-1").and_return(q_results)
          @obj = EdgeGateway.get_by_name('edgegw-test-1')
          expect(@obj.id).to eq(@edgegw_id)
        end

        it "should raise an error if no edgegw with that name exists" do
          q_results = [ ]
          mock_query = double(:query_runner)
          Vcloud::Core::QueryRunner.should_receive(:new).and_return(mock_query)
          mock_query.should_receive(:run).with('edgeGateway', :filter => "name==edgegw-test-1").and_return(q_results)
          expect{ EdgeGateway.get_by_name('edgegw-test-1') }.to raise_exception(RuntimeError, "edgeGateway edgegw-test-1 not found")
        end

      end

      context "Interface related tests" do

        before(:each) do
          @valid_ext_id = "12345678-70ac-487e-9c1e-124716764274"
          @valid_int_id = "12345678-70ac-487e-9c1e-552f1f0a91dc"
          edge_gateway_hash = {
            :Configuration=>
              {:GatewayBackingConfig=>"compact",
               :GatewayInterfaces=>
                {:GatewayInterface=>
                  [{:Name=>"EXTERNAL_NETWORK",
                    :Network=>
                     {:type=>"application/vnd.vmware.admin.network+xml",
                      :name=>"EXTERNAL_NETWORK",
                      :href=>
                       "https://example.com/api/admin/network/#{@valid_ext_id}"},
                    :InterfaceType=>"uplink",
                    :SubnetParticipation=>
                     {:Gateway=>"192.2.0.1",
                      :Netmask=>"255.255.255.0",
                      :IpAddress=>"192.2.0.66"},
                    :UseForDefaultRoute=>"true"},
                   {:Name=>"INTERNAL_NETWORK",
                    :Network=>
                     {:type=>"application/vnd.vmware.admin.network+xml",
                      :name=>"INTERNAL_NETWORK",
                      :href=>
                       "https://example.com/api/admin/network/#{@valid_int_id}"},
                    :InterfaceType=>"internal",
                    :SubnetParticipation=>
                     {:Gateway=>"192.168.1.1",
                      :Netmask=>"255.255.255.0",
                      :IpAddress=>"192.168.1.55"},
                    :UseForDefaultRoute=>"false"
                   },
                  ]
                }
              }
          }
          @mock_fog_interface.should_receive(:get_edge_gateway).
            and_return(edge_gateway_hash)
          @edgegw = EdgeGateway.new(@edgegw_id)
        end

        context "#vcloud_gateway_interface_by_id" do

          it "should return nil if the network id is not found" do
            expect(@edgegw.vcloud_gateway_interface_by_id(
                 '12345678-1234-1234-1234-123456789012')).
              to be_nil
          end

          it "should return a vcloud network hash if the network id is found" do
            expect(@edgegw.vcloud_gateway_interface_by_id(@valid_int_id)).
              to eq(
                     {:Name=>"INTERNAL_NETWORK",
                      :Network=>
                       {:type=>"application/vnd.vmware.admin.network+xml",
                        :name=>"INTERNAL_NETWORK",
                        :href=>
                         "https://example.com/api/admin/network/#{@valid_int_id}"},
                      :InterfaceType=>"internal",
                      :SubnetParticipation=>
                       {:Gateway=>"192.168.1.1",
                        :Netmask=>"255.255.255.0",
                        :IpAddress=>"192.168.1.55"},
                      :UseForDefaultRoute=>"false"
                     },
                   )
          end
        end

        context "#interfaces" do

          it "should return an array of EdgeGatewayInterface objects" do
            interfaces_list = @edgegw.interfaces
            expect(interfaces_list.class).to be(Array)
            expect(interfaces_list.first.class).to be(Vcloud::Core::EdgeGatewayInterface)
          end

        end

      end

    end

  end

end
