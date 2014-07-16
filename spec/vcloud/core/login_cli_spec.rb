require 'spec_helper'

class LoginCommandRun
  attr_accessor :stdout, :stderr, :exitstatus

  def initialize(args, stdin=nil)
    out = StringIO.new
    err = StringIO.new

    if stdin
      $stdin = StringIO.new
      $stdin << stdin
      $stdin.rewind
    end
    $stdout = out
    $stderr = err

    begin
      Vcloud::Core::LoginCli.new(args).run
      @exitstatus = 0
    rescue SystemExit => e
      # Capture exit(n) value.
      @exitstatus = e.status
    end

    @stdout = out.string.strip
    @stderr = err.string.strip

    if stdin
      $stdin = STDIN
    end
    $stdout = STDOUT
    $stderr = STDERR
  end
end

describe Vcloud::Core::LoginCli do
  let(:stdin) { nil }
  subject { LoginCommandRun.new(args, stdin) }

  describe "normal usage" do
    context "when given no arguments and a password on stdin" do
      let(:args) { %w{} }
      let(:pass) { 'supersekret' }
      let(:stdin) { pass }

      context "interactive tty" do
        before(:each) do
          expect(STDIN).to receive(:tty?).and_return(true)
        end

        it "should prompt on stderr so that stdout can be scripted and mask password input" do
          expect(Vcloud::Fog::Login).to receive(:token_export).with(pass)
          expect(subject.stderr).to eq("vCloud password: " + "*" * pass.size)
        end
      end

      context "non-interactive tty" do
        before(:each) do
          expect(STDIN).to receive(:tty?).and_return(false)
        end

        it "should write stderr message to say that it's reading from pipe and not echo any input" do
          expect(Vcloud::Fog::Login).to receive(:token_export).with(pass)
          expect(subject.stderr).to eq("Reading password from pipe..")
        end
      end
    end

    context "when asked to display version" do
      let(:args) { %w{--version} }

      it "should not call Login" do
        expect(Vcloud::Fog::Login).not_to receive(:token_export)
      end

      it "should print version and exit normally" do
        expect(subject.stdout).to eq(Vcloud::Core::VERSION)
        expect(subject.exitstatus).to eq(0)
      end
    end

    context "when asked to display help" do
      let(:args) { %w{--help} }

      it "should not call Login" do
        expect(Vcloud::Fog::Login).not_to receive(:token_export)
      end

      it "should print usage and exit normally" do
        expect(subject.stderr).to match(/\AUsage: \S+ \[options\]\n/)
        expect(subject.exitstatus).to eq(0)
      end
    end
  end

  describe "incorrect usage" do
    shared_examples "print usage and exit abnormally" do |error|
      it "should not call Login" do
        expect(Vcloud::Fog::Login).not_to receive(:token_export)
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
      let(:stdin) { "" }

      it "should print error without backtrace and exit abnormally" do
        expect(Vcloud::Fog::Login).to receive(:token_export).
          with("").and_raise('something went horribly wrong')
        expect(subject.stderr).to eq("vCloud password: \nsomething went horribly wrong")
        expect(subject.exitstatus).to eq(1)
      end
    end
  end
end
