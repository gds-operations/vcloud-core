require 'spec_helper'
require 'stringio'

describe Vcloud::Fog::Login do
  describe "#token" do
    it "should return the output from get_token" do
      expect(subject).to receive(:check_plaintext_pass)
      expect(subject).to receive(:get_token).and_return('mekmitasdigoat')
      expect(subject.token('supersekret')).to eq("mekmitasdigoat")
    end
  end

  describe "#token_export" do
    it "should call #token with pass arg and return shell export string" do
      expect(subject).to receive(:token).with('supersekret').and_return('mekmitasdigoat')
      expect(subject.token_export("supersekret")).to eq("export FOG_VCLOUD_TOKEN=mekmitasdigoat")
    end
  end

  describe "#check_plaintext_pass" do
    context "vcloud_director_password not set" do
      it "should not raise an exception" do
        expect(Fog).to receive(:credentials).and_return({})
        expect(subject).to receive(:get_token)
        expect { subject.token('supersekret') }.not_to raise_error
      end
    end

    context "vcloud_director_password empty string" do
      it "should not raise an exception" do
        expect(Fog).to receive(:credentials).and_return({
          :vcloud_director_password => '',
        })
        expect(subject).to receive(:get_token)
        expect { subject.token('supersekret') }.not_to raise_error
      end
    end

    context "vcloud_director_password non-empty string" do
      it "should raise an exception" do
        expect(Fog).to receive(:credentials).and_return({
          :vcloud_director_password => 'supersekret',
        })
        expect(subject).to_not receive(:get_token)
        expect { subject.token('supersekret') }.to raise_error(
          RuntimeError,
          "Found plaintext vcloud_director_password entry. Please set it to an empty string"
        )
      end
    end
  end
end
