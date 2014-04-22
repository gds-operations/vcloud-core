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

    end
  end
end

