require 'spec_helper'

describe Vcloud::Fog::Login do
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

    context "unable to load credentials" do
      it "should raise an exception succinctly listing the missing credentials" do
        mock_env.clear
        ::Fog.credential = 'null'
        ::Fog.credentials_path = '/dev/null'

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
