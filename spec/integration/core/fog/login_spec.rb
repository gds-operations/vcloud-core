require 'spec_helper'

describe Vcloud::Core::Fog::Login do
  before(:each) do
    stub_const('ENV', {})

    @orig_credential = ::Fog.credential
    ::Fog.credential = 'null'
    @orig_credentials_path = ::Fog.credentials_path
    ::Fog.credentials_path = '/dev/null'
  end

  after(:each) do
    ::Fog.credential = @orig_credential
    ::Fog.credentials_path = @orig_credentials_path
  end

  describe "#token" do
    context "unable to load credentials" do
      it "should raise an exception succinctly listing the missing credentials" do
        # This test is known to fail with a TypeError due to a bug in Ruby 1.9.3 that
        # has since been fixed. See https://github.com/gds-operations/vcloud-core/pull/100
        expect { ::Fog.credentials['doesnotexist'] }.to raise_error(
          Fog::Errors::LoadError,
          /^Missing Credentials\n/
        )
        expect { subject.token('supersekret') }.to raise_error(
          ArgumentError,
          /^Missing required arguments: vcloud_director_.*$/
        )
      end
    end
  end
end
