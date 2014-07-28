require 'spec_helper'

describe Vcloud::Fog do
  describe "fog_credentials_pass" do
    let(:subject) { Vcloud::Fog::fog_credentials_pass }

    context "vcloud_director_password not set" do
      it "should return nil" do
        expect(::Fog).to receive(:credentials).and_return({})
        expect(subject).to eq(nil)
      end
    end

    context "vcloud_director_password set" do
      it "should return string" do
        expect(::Fog).to receive(:credentials).and_return({
          :vcloud_director_password => 'supersekret',
        })
        expect(subject).to eq('supersekret')
      end
    end

    context "Fog LoadError" do
      it "should suppress exception and return nil" do
        expect(::Fog).to receive(:credentials).and_raise(::Fog::Errors::LoadError)
        expect(subject).to eq(nil)
      end
    end
  end
end
