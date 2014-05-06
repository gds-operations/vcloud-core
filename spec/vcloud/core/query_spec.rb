require 'spec_helper'

describe Vcloud::Core::Query do
  context "attributes" do

    context "#run called with no type set on construction" do

      it "should output all types that are available" do
        query_runner = double(Vcloud::Core::QueryRunner)
        allow(query_runner).to receive(:available_query_types) { [ 'alice', 'bob' ] }

        @query = Vcloud::Core::Query.new(nil, {}, query_runner)

        @query.should_receive(:puts).with("alice")
        @query.should_receive(:puts).with("bob")

        @query.run
      end

    end

    context "gracefully handle zero results" do

      before(:each) do
        @query_runner = double(Vcloud::Core::QueryRunner)
        allow(@query_runner).to receive(:run) { {} }
      end

      it "should not output when given tsv output_format" do
        query = Vcloud::Core::Query.new('bob', {:output_format => 'tsv'}, @query_runner)

        query.should_not_receive(:puts)

        query.run()
      end

      it "should not output when given csv output_format" do
        query = Vcloud::Core::Query.new('bob', {:output_format => 'csv'}, @query_runner)

        query.should_not_receive(:puts)

        query.run()
      end

    end

    context "get results with a single response page" do

      before(:each) do
        @query_runner = double(Vcloud::Core::QueryRunner)
        allow(@query_runner).to receive(:run) {
          [
            {:field1 => "Stuff 1", :field2 => "Stuff 2"},
            {:field1 => "More Stuff 1", :field2 => "More Stuff 2"}
          ]
        }
      end

      it "should output a query in tsv when run with a type" do
        @query = Vcloud::Core::Query.new('bob', {:output_format => 'tsv'}, @query_runner)

        @query.should_receive(:puts).with("field1\tfield2")
        @query.should_receive(:puts).with("Stuff 1\tStuff 2")
        @query.should_receive(:puts).with("More Stuff 1\tMore Stuff 2")

        @query.run()
      end

      it "should output a query in csv when run with a type" do
        @query = Vcloud::Core::Query.new('bob', {:output_format => 'csv'}, @query_runner)

        @query.should_receive(:puts).with("field1,field2\n")
        @query.should_receive(:puts).with("Stuff 1,Stuff 2\nMore Stuff 1,More Stuff 2\n")

        @query.run()
      end

    end

  end

end
