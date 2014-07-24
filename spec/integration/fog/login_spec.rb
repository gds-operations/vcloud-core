require 'spec_helper'

describe Vcloud::Fog::Login do
  let!(:mock_env) { ENV.clone }

  before(:each) do
    stub_const('ENV', mock_env)
  end

  describe "#token" do
    context "unable to load credentials" do
      it "should raise an exception succinctly listing the missing credentials" do
        mock_env.clear
        ::Fog.credential = 'null'
        ::Fog.credentials_path = '/dev/null'

        # This test is known to fail with a TypeError due to a bug in Ruby 1.9.3 that
        # has since been fixed. See https://github.com/gds-operations/vcloud-core/pull/100
        expect { ::Fog.credentials['doesnotexist'] }.to raise_error(
          Fog::Errors::LoadError,
          /^Missing Credentials\n/
        )
        expect { subject.token(@real_password) }.to raise_error(
          ArgumentError,
          /^Missing required arguments: vcloud_director_.*$/
        )
      end
    end
  end
end
