require 'spec_helper'

module Vcloud
  module Core
    describe QueryRunner do

      context "#available_query_types" do

        before(:all) do
          @query_types = QueryRunner.new.available_query_types
        end

        context "confirm accessing the query API is functional" do

          it "should return an Array of available query types" do
            expect(@query_types.class).to eq(Array)
          end

          it "should return at least one query type" do
            expect(@query_types.size).to be >= 1
          end

        end

        context "must support all the vCloud entity types our tools need, in 'records' format" do

          it "must support the vApp entity type" do
            expect(@query_types.detect { |a| a == [ "vApp", "records" ] }).to be_true
          end

          it "must support the vm entity type" do
            expect(@query_types.detect { |a| a == [ "vm", "records" ] }).to be_true
          end

          it "must support the orgVdc entity type" do
            expect(@query_types.detect { |a| a == [ "orgVdc", "records" ] }).to be_true
          end

          it "must support the orgVdcNetwork entity type" do
            expect(@query_types.detect { |a| a == [ "orgVdcNetwork", "records" ] }).to be_true
          end

          it "must support the edgeGateway entity type" do
            expect(@query_types.detect { |a| a == [ "edgeGateway", "records" ] }).to be_true
          end

          it "must support the task entity type" do
            expect(@query_types.detect { |a| a == [ "task", "records" ] }).to be_true
          end

          it "must support the catalog entity type" do
            expect(@query_types.detect { |a| a == [ "catalog", "records" ] }).to be_true
          end

          it "must support the catalogItem entity type" do
            expect(@query_types.detect { |a| a == [ "catalogItem", "records" ] }).to be_true
          end

          it "must support the vAppTemplate entity type" do
            expect(@query_types.detect { |a| a == [ "vAppTemplate", "records" ] }).to be_true
          end

        end

      end

      context "#run" do

        context "when called with type vAppTemplate and no options" do

          before(:all) do
            @results = QueryRunner.new.run('vAppTemplate')
          end

          it "should have returned a results Array" do
            expect(@results.class).to eq(Array)
          end

          it "should have returned at least one result" do
            expect(@results.size).to be > 1
          end

          it "each results element should be a Hash" do
            expect(@results.first.class).to eq(Hash)
          end

          it "result should have a defined name element" do
            expect(@results.first[:name]).to be_true
          end

          it "result should have a defined href element" do
            expect(@results.first[:href]).to be_true
          end

          it "result should have a defined vdcName element" do
            expect(@results.first[:vdcName]).to be_true
          end

          it "result should have a defined isDeployed element" do
            expect(@results.first[:isDeployed]).to be_true
          end

          it "result should not have a 'bogusElement' element" do
            expect(@results.first.key?(:bogusElement)).to be false
          end

        end

        context "when called with type vAppTemplate and output fields limited to name & vdcName" do

          before(:all) do
            @results = QueryRunner.new.run('vAppTemplate', fields: "name,vdcName")
          end

          it "result should have a defined href element" do
            expect(@results.first[:name]).to be_true
          end

          it "result should have a defined name element" do
            expect(@results.first[:name]).to be_true
          end

          it "result should have a defined vdcName element" do
            expect(@results.first[:vdcName]).to be_true
          end

          it "result should not have a isDeployed key" do
            expect(@results.first.key?(:isDeployed)).to be false
          end

        end

      end

    end
  end
end

