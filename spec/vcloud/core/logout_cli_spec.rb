require 'spec_helper'

class LogoutCommandRun
  attr_accessor :stdout, :stderr, :exitstatus

  def initialize(args)
    out = StringIO.new
    err = StringIO.new

    $stdout = out
    $stderr = err

    begin
      Vcloud::Core::LogoutCli.new(args).run
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

describe Vcloud::Core::LogoutCli do
  subject { LogoutCommandRun.new(args) }

  describe "normal usage" do
    context "when given no arguments" do
      let(:args) { %w{} }

      it "should " do
        expect(Vcloud::Core::Fog).to receive(:logout).and_return({})
        expect(subject.stderr).to eq("")
        expect(subject.exitstatus).to eq(0)
      end
    end

    context "when asked to display version" do
      let(:args) { %w{--version} }

      it "should not call Logout" do
        expect(Vcloud::Core::Fog).not_to receive(:logout)
      end

      it "should print version and exit normally" do
        expect(subject.stdout).to eq(Vcloud::Core::VERSION)
        expect(subject.exitstatus).to eq(0)
      end
    end

    context "when asked to display help" do
      let(:args) { %w{--help} }

      it "should not call Logout" do
        expect(Vcloud::Core::Fog).not_to receive(:logout)
      end

      it "should print usage and exit normally" do
        expect(subject.stderr).to match(/\AUsage: \S+ \[options\]\n/)
        expect(subject.exitstatus).to eq(0)
      end
    end
  end

  describe "incorrect usage" do
    shared_examples "print usage and exit abnormally" do |error|
      it "should not call Logout" do
        expect(Vcloud::Core::Fog).not_to receive(:logout)
      end

      it "should print error message and usage" do
        expect(subject.stderr).to match(/\A\S+: #{error}\nUsage: \S+/)
      end

      it "should exit abnormally for incorrect usage" do
        expect(subject.exitstatus).to eq(2)
      end
    end

    context "when given more than one argument" do
      let(:args) { %w{an_extra_arg} }

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
      let(:exception) { RuntimeError.new('something went horribly wrong') }

      it "should print error without backtrace and exit abnormally" do
        expect(Vcloud::Core::Fog).to receive(:logout).and_raise(exception)
        expect(subject.stderr).to eq("RuntimeError: something went horribly wrong")
        expect(subject.exitstatus).to eq(1)
      end
    end
  end
end
