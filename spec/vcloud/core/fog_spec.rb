require 'spec_helper'

describe Vcloud::Core::Fog do
  describe "logout" do
    let(:subject) { Vcloud::Core::Fog::logout }
    let(:envvar_token) { 'FOG_VCLOUD_TOKEN' }

    context "token environment variable not set" do
      before(:each) do
        stub_const('ENV', {})
      end

      it "should raise an error" do
        expect(Vcloud::Core::Fog::ServiceInterface).not_to receive(:new)
        expect { subject }.to raise_error(
          RuntimeError, "FOG_VCLOUD_TOKEN environment variable is not set"
        )
      end
    end
  end

  describe "fog_credentials_pass" do
    let(:subject) { Vcloud::Core::Fog::fog_credentials_pass }

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
