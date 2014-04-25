require 'spec_helper'

module Vcloud
  module Core
    describe QueryRunner do

      required_env = {
        'VCLOUD_VDC_NAME' =>
           'to the name of an orgVdc to use to instanciate vApps into',
        'VCLOUD_TEMPLATE_NAME' =>
           'to the name of a vAppTemplate to use create vApps in tests',
        'VCLOUD_CATALOG_NAME' =>
           'to the name of the catalog that VCLOUD_VAPP_TEMPLATE_NAME is stored in',
      }

      error = false
      required_env.each do |var,message|
        unless ENV[var]
          puts "Must set #{var} #{message}" unless ENV[var]
          error = true
        end
      end
      Kernel.exit(2) if error

      before(:all) do
        @vapp_template_name = ENV['VCLOUD_TEMPLATE_NAME']
        @vapp_template_catalog_name = ENV['VCLOUD_CATALOG_NAME']
        @vdc_name = ENV['VCLOUD_VDC_NAME']
      end

      context "#available_query_types" do

        before(:all) do
          @query_types = QueryRunner.new.available_query_types
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
            expect(@query_types.detect { |a| a == [ "vApp", "records" ] }).to be_true
          end

          it "supports the vm entity type" do
            expect(@query_types.detect { |a| a == [ "vm", "records" ] }).to be_true
          end

          it "supports the orgVdc entity type" do
            expect(@query_types.detect { |a| a == [ "orgVdc", "records" ] }).to be_true
          end

          it "supports the orgVdcNetwork entity type" do
            expect(@query_types.detect { |a| a == [ "orgVdcNetwork", "records" ] }).to be_true
          end

          it "supports the edgeGateway entity type" do
            expect(@query_types.detect { |a| a == [ "edgeGateway", "records" ] }).to be_true
          end

          it "supports the task entity type" do
            expect(@query_types.detect { |a| a == [ "task", "records" ] }).to be_true
          end

          it "supports the catalog entity type" do
            expect(@query_types.detect { |a| a == [ "catalog", "records" ] }).to be_true
          end

          it "supports the catalogItem entity type" do
            expect(@query_types.detect { |a| a == [ "catalogItem", "records" ] }).to be_true
          end

          it "supports the vAppTemplate entity type" do
            expect(@query_types.detect { |a| a == [ "vAppTemplate", "records" ] }).to be_true
          end

        end

      end

      context "#run" do

        before(:all) do
          @number_of_vapps_to_create = 2
          @test_case_vapps = create_test_case_vapps(
            @number_of_vapps_to_create,
            @vdc_name,
            @vapp_template_catalog_name,
            @vapp_template_name,
          )
        end

        context "vApps are queriable with no options specified" do

          before(:all) do
            @all_vapps = QueryRunner.new.run('vApp')
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

        context "vApp query output fields can be limited to 'name,vdcName'" do

          before(:all) do
            @results = QueryRunner.new.run('vApp', fields: "name,vdcName")
          end

          it "returns a record with a defined href element" do
            expect(@results.first[:href]).not_to be_empty
          end

          it "returns a record with a defined name element" do
            expect(@results.first[:href]).not_to be_empty
          end

          it "returns a record with a defined vdcName element" do
            expect(@results.first[:vdcName]).not_to be_empty
          end

          it "does not return a 'status' record" do
            expect(@results.first.key?(:status)).to be false
          end

        end

        context "query output can be restricted by a filter expression on name" do

          before(:all) do
            @vapp_name = @test_case_vapps.last.name
            @filtered_results = QueryRunner.new.run('vApp', filter: "name==#{@vapp_name}")
          end

          it "returns a single record matching our filter on name" do
            expect(@filtered_results.size).to be(1)
            expect(@filtered_results.first.fetch(:name)).to eq(@vapp_name)
          end

        end

        after(:all) do
          fsi = Vcloud::Fog::ServiceInterface.new()
          @test_case_vapps.each do |vapp|
            fsi.delete_vapp(vapp.id)
          end
        end

        def create_test_case_vapps(quantity, vdc_name, catalog_name, vapp_template_name)
          vapp_template = VappTemplate.get(catalog_name, vapp_template_name)
          timestamp_in_s = Time.new.to_i
          base_vapp_name = "vcloud-core-query-tests-#{timestamp_in_s}-"
          network_names = []
          vapp_list = []
          quantity.times do |index|
            vapp_list << Vapp.instantiate(
              base_vapp_name + index.to_s,
              network_names,
              vapp_template.id,
              vdc_name
            )
          end
          vapp_list
        end

      end

    end
  end
end

