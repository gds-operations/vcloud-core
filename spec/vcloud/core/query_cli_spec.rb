require 'spec_helper'

class CommandRun
  attr_accessor :stdout, :stderr, :exitstatus

  def initialize(args)
    out = StringIO.new
    err = StringIO.new

    $stdout = out
    $stderr = err

    begin
      Vcloud::Core::QueryCli.new(args).run
      @exitstatus = 0
    rescue SystemExit => e
      # Capture exit(n) value.
      @exitstatus = e.status
    end

    @stdout = out.string.strip
    @stderr = err.string.strip

    $stdout = STDOUT
    $stderr = STDERR
  end
end

describe Vcloud::Core::QueryCli do
  subject { CommandRun.new(args) }
  let(:mock_query) {
    double(:query, :run => true)
  }

  describe "normal usage" do
    context "when given no arguments" do
      let(:args) { %w{} }

      it "should pass nil type and empty options hash, then exit normally" do
        expect(Vcloud::Core::Query).to receive(:new).
          with(nil, {}).and_return(mock_query)
        expect(mock_query).to receive(:run)
        expect(subject.exitstatus).to eq(0)
      end
    end

    context "when given type" do
      let(:args) { %w{vApp} }

      it "should pass type and empty options hash, then exit normally" do
        expect(Vcloud::Core::Query).to receive(:new).
          with('vApp', {}).and_return(mock_query)
        expect(mock_query).to receive(:run)
        expect(subject.exitstatus).to eq(0)
      end
    end

    context "when asked to display version" do
      let(:args) { %w{--version} }

      it "should not call Query" do
        expect(Vcloud::Core::Query).not_to receive(:new)
      end

      it "should print version and exit normally" do
        expect(subject.stdout).to eq(Vcloud::Core::VERSION)
        expect(subject.exitstatus).to eq(0)
      end
    end

    context "when asked to display help" do
      let(:args) { %w{--help} }

      it "should not call Query" do
        expect(Vcloud::Core::Query).not_to receive(:new)
      end

      it "should print usage and exit normally" do
        expect(subject.stderr).to match(/\AUsage: \S+ \[options\] \[type\]\n/)
        expect(subject.exitstatus).to eq(0)
      end
    end
  end

  describe "simple arguments with values" do
    {
      :sortAsc  => '--sort-asc',
      :sortDesc => '--sort-desc',
      :fields   => '--fields',
      :filter   => '--filter',
    }.each do |options_key, cli_arg|
      context "when given #{cli_arg}" do
        let(:args) { [cli_arg, 'giraffe'] }

        it "should pass :#{options_key} in options hash and exit normally" do
          expect(Vcloud::Core::Query).to receive(:new).
            with(nil, { options_key => 'giraffe' }).
            and_return(mock_query)
          expect(mock_query).to receive(:run)
          expect(subject.exitstatus).to eq(0)
        end
      end
    end
  end

  describe "complex arguments with values" do
    context "when given --output-format with mixed case value" do
      let(:args) { %w{--output-format MixedCaseValue} }

      it "should pass downcased value in options hash and exit normally" do
        expect(Vcloud::Core::Query).to receive(:new).
          with(nil, { :output_format => 'mixedcasevalue' }).
          and_return(mock_query)
        expect(mock_query).to receive(:run)
        expect(subject.exitstatus).to eq(0)
      end
    end
  end

  describe "incorrect usage" do
    shared_examples "print usage and exit abnormally" do |error|
      it "should not call Query" do
        expect(Vcloud::Core::Query).not_to receive(:new)
      end

      it "should print error message and usage" do
        expect(subject.stderr).to match(/\A\S+: #{error}\nUsage: \S+/)
      end

      it "should exit abnormally for incorrect usage" do
        expect(subject.exitstatus).to eq(2)
      end
    end

    context "when given more than type argument" do
      let(:args) { %w{type_one type_two} }

      it_behaves_like "print usage and exit abnormally", "too many arguments"
    end

    context "when given an unrecognised argument" do
      let(:args) { %w{--this-is-garbage} }

      it_behaves_like "print usage and exit abnormally", "invalid option: --this-is-garbage"
    end
  end

  describe "error handling" do
    context "when underlying code raises an exception" do
      let(:args) { %w{} }

      it "should print error without backtrace and exit abnormally" do
        expect(Vcloud::Core::Query).to receive(:new).
          with(nil, {}).and_raise("something went horribly wrong")
        expect(subject.stderr).to eq("something went horribly wrong")
        expect(subject.exitstatus).to eq(1)
      end
    end
  end
end
