require 'spec_helper'
require 'stringio'

describe Vcloud::Fog::Login do
  describe "#token" do
    before(:each) do
      expect(subject).to receive(:check_plaintext_pass)
    end

    context "password not supplied" do
      it "should call prompt_pass and return token" do
        expect(subject).to receive(:prompt_pass).and_return('supersekret')
        expect(subject).to receive(:get_token).and_return('mekmitasdigoat')
        expect(subject.token).to eq("mekmitasdigoat")
      end
    end

    context "password supplied" do
      it "should return token without calling prompt_pass" do
        expect(subject).not_to receive(:prompt_pass)
        expect(subject).to receive(:get_token).and_return('mekmitasdigoat')
        expect(subject.token("supersekret")).to eq("mekmitasdigoat")
      end
    end
  end

  describe "#token_export" do
    context "password not supplied" do
      it "should call #token with no args and return shell export string" do
        expect(subject).to receive(:token).with(no_args()).and_return('mekmitasdigoat')
        expect(subject.token_export).to eq("export FOG_VCLOUD_TOKEN=mekmitasdigoat")
      end
    end

    context "password supplied" do
      it "should call #token with pass arg and return shell export string" do
        expect(subject).to receive(:token).with('supersekret').and_return('mekmitasdigoat')
        expect(subject.token_export("supersekret")).to eq("export FOG_VCLOUD_TOKEN=mekmitasdigoat")
      end
    end
  end

  describe "#check_plaintext_pass" do
    context "vcloud_director_password not set" do
      it "should not raise an exception" do
        expect(Fog).to receive(:credentials).and_return({})
        expect { subject.check_plaintext_pass }.not_to raise_error
      end
    end

    context "vcloud_director_password empty string" do
      it "should not raise an exception" do
        expect(Fog).to receive(:credentials).and_return({
          :vcloud_director_password => '',
        })
        expect { subject.check_plaintext_pass }.not_to raise_error
      end
    end

    context "vcloud_director_password non-empty string" do
      it "should raise an exception" do
        expect(Fog).to receive(:credentials).and_return({
          :vcloud_director_password => 'supersekret',
        })
        expect { subject.check_plaintext_pass }.to raise_error(
          RuntimeError,
          "Found plaintext vcloud_director_password entry. Please set it to an empty string"
        )
      end
    end
  end

  describe "#prompt_pass" do
    let(:pass) { 'supersekret' }

    before(:each) do
      $stdin = StringIO.new()
      $stdin << pass
      $stdin.rewind
    end

    after(:each) do
      $stdin = STDIN
    end

    it "should prompt for password on stderr so that stdout can be scripted" do
      expect($stderr).to receive(:write).with("Enter vCloud password: ")
      allow($stderr).to receive(:write)
      subject.prompt_pass
    end

    it "should mask password with asterisks" do
      expect($stderr).to receive(:write).with("*").exactly(pass.size).times
      allow($stderr).to receive(:write)
      subject.prompt_pass
    end

    it "should return password from stdin" do
      allow($stderr).to receive(:write)
      expect(subject.prompt_pass).to eq(pass)
    end
  end
end
