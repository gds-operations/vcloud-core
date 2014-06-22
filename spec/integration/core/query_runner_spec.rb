require 'spec_helper'

module Vcloud
  module Core
    describe QueryRunner do

      before(:all) do
        config_file = File.join(File.dirname(__FILE__), "../vcloud_tools_testing_config.yaml")
        test_params = Vcloud::Tools::Tester::TestParameters.new(config_file)
        @vapp_template_name = test_params.vapp_template
        @vapp_template_catalog_name = test_params.catalog
        @vdc_name = test_params.vdc_1_name
      end

      context "#available_query_types" do

        before(:all) do
          @query_types = Vcloud::Core::QueryRunner.new.available_query_types
        end

        context "confirm accessing the query API is functional" do

          it "returns an Array of available query types" do
            expect(@query_types.class).to eq(Array)
          end

          it "returns at least one query type" do
            expect(@query_types.size).to be >= 1
          end

        end

        context "it supports all the vCloud entity types our tools need" do

          it "supports the vApp entity type" do
            expect(@query_types.include?("vApp")).to be_true
          end

          it "supports the vm entity type" do
            expect(@query_types.include?("vm")).to be_true
          end

          it "supports the orgVdc entity type" do
            expect(@query_types.include?("orgVdc")).to be_true
          end

          it "supports the orgVdcNetwork entity type" do
            expect(@query_types.include?("orgVdcNetwork")).to be_true
          end

          it "supports the edgeGateway entity type" do
            expect(@query_types.include?("edgeGateway")).to be_true
          end

          it "supports the task entity type" do
            expect(@query_types.include?("task")).to be_true
          end

          it "supports the catalog entity type" do
            expect(@query_types.include?("catalog")).to be_true
          end

          it "supports the catalogItem entity type" do
            expect(@query_types.include?("catalogItem")).to be_true
          end

          it "supports the vAppTemplate entity type" do
            expect(@query_types.include?("vAppTemplate")).to be_true
          end

        end

      end

      context "#run" do

        before(:all) do
          @number_of_vapps_to_create = 2
          @test_case_vapps = IntegrationHelper.create_test_case_vapps(
            @number_of_vapps_to_create,
            @vdc_name,
            @vapp_template_catalog_name,
            @vapp_template_name,
            [],
            "vcloud-core-query-tests"
          )
        end

        context "vApps are queriable with no options specified" do

          before(:all) do
            @all_vapps = Vcloud::Core::QueryRunner.new.run('vApp')
          end

          it "returns an Array" do
            expect(@all_vapps.class).to eq(Array)
          end

          it "returns at least the number of vApps that we created" do
            expect(@all_vapps.size).to be >= @number_of_vapps_to_create
          end

          it "returns a record with a defined :name field" do
            expect(@all_vapps.first[:name]).not_to be_empty
          end

          it "returns a record with a defined :href field" do
            expect(@all_vapps.first[:href]).not_to be_empty
          end

          it "returns a record with a defined :vdcName field" do
            expect(@all_vapps.first[:vdcName]).not_to be_empty
          end

          it "returns a record with a defined :status field" do
            expect(@all_vapps.first[:status]).not_to be_empty
          end

          it "does not return a 'bogusElement' element" do
            expect(@all_vapps.first.key?(:bogusElement)).to be false
          end

        end

        context "Query output fields can be limited by supplying a comma-separated :fields list" do

          before(:all) do
            @results = Vcloud::Core::QueryRunner.new.run('vApp', fields: "name,vdcName")
          end

          it "returns a record with a defined name element" do
            expect(@results.first[:name]).not_to be_empty
          end

          it "returns a record with a defined vdcName element" do
            expect(@results.first[:vdcName]).not_to be_empty
          end

          it "does not return a 'status' record, which we know is available for our vApp type" do
            expect(@results.first.key?(:status)).to be false
          end

        end

        context "Query API does not support an empty :fields list" do

          it "raises a BadRequest exception, if empty string is supplied for :fields" do
            expect { Vcloud::Core::QueryRunner.new.run('vApp', fields: "") }.
              to raise_exception(::Fog::Compute::VcloudDirector::BadRequest)
          end

        end

        context "Query API returns href field regardless of filter :fields selected" do

          it "returns href as well as name, if just 'name' is asked for" do
            results = Vcloud::Core::QueryRunner.new.run('vApp', fields: "name")
            expect(results.first.keys.sort).to eq([:href, :name])
          end

          it "returns href, name, vdcName if 'name,vdcName' is asked for" do
            results = Vcloud::Core::QueryRunner.new.run('vApp', fields: "name,vdcName")
            expect(results.first.keys.sort).to eq([:href, :name, :vdcName])
          end

        end

        context "query output can be restricted by a filter expression on name" do

          before(:all) do
            @vapp_name = @test_case_vapps.last.name
            @filtered_results = Vcloud::Core::QueryRunner.new.run('vApp', filter: "name==#{@vapp_name}")
          end

          it "returns a single record matching our filter on name" do
            expect(@filtered_results.size).to be(1)
            expect(@filtered_results.first.fetch(:name)).to eq(@vapp_name)
          end

        end

        after(:all) do
          IntegrationHelper.delete_vapps(@test_case_vapps)
        end

      end

    end
  end
end

