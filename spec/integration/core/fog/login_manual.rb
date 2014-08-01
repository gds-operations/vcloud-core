require 'spec_helper'

# These tests, which confirm that the Fog internals are performing a login
# and returning a new token, are not run automatically because they conflict
# with the use of vcloud-login in CI. Because we're using vcloud-login all
# of our tests should fail if the behaviour of Fog changes. However these
# may came in useful when debugging such a scenario.

describe Vcloud::Core::Fog::Login do
  let!(:mock_env) { ENV.clone }

  before(:each) do
    stub_const('ENV', mock_env)
  end

  describe "#token" do
    context "fog credentials without password" do
      let(:token_length) { 44 }
      let(:env_var_name) { 'FOG_VCLOUD_TOKEN' }
      let!(:mock_fog_creds) { ::Fog.credentials.clone }

      before(:each) do
        @real_password = mock_fog_creds.delete(:vcloud_director_password)
        allow(::Fog).to receive(:credentials).and_return(mock_fog_creds)
      end

      context "environment variable VCLOUD_FOG_TOKEN not set" do
        it "should login and return a token" do
          mock_env.delete(env_var_name)
          token = subject.token(@real_password)
          expect(token.size).to eq(token_length)
        end
      end

      context "environment variable VCLOUD_FOG_TOKEN is set" do
        let(:old_token) { 'mekmitasdigoat' }

        it "should login and return a token, ignoring the existing token" do
          mock_env[env_var_name] = old_token
          new_token = subject.token(@real_password)
          expect(new_token).to_not eq(old_token)
          expect(new_token.size).to eq(token_length)
        end
      end
    end
  end
end
