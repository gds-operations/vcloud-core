require 'spec_helper'

module Vcloud
  module Core
    describe QueryRunner do

      context "#available_query_types" do

        before(:all) do
          @query_types = QueryRunner.new.available_query_types
        end

        it "should return an Array of available query types" do
          expect(@query_types.class).to eq(Array)
        end

        it "should return at least one query type" do
          expect(@query_types.size).to be > 1
        end

        it "should return a vApp type" do
          expect(@query_types.detect { |a| a.first == "vApp" }).to be_true
        end

        it "should return a vm type" do
          expect(@query_types.detect { |a| a.first == "vm" }).to be_true
        end

        it "should return an orgVdc type" do
          expect(@query_types.detect { |a| a.first == "orgVdc" }).to be_true
        end

        it "should return an orgVdcNetwork type" do
          expect(@query_types.detect { |a| a.first == "orgVdcNetwork" }).to be_true
        end

        it "should return an edgeGateway type" do
          expect(@query_types.detect { |a| a.first == "edgeGateway" }).to be_true
        end

        it "should return a task type" do
          expect(@query_types.detect { |a| a.first == "task" }).to be_true
        end

        it "should return a catalog type" do
          expect(@query_types.detect { |a| a.first == "catalog" }).to be_true
        end

        it "should return a catalogItem type" do
          expect(@query_types.detect { |a| a.first == "catalogItem" }).to be_true
        end

        it "should return a vAppTemplate type" do
          expect(@query_types.detect { |a| a.first == "vAppTemplate" }).to be_true
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

      end

    end
  end
end

