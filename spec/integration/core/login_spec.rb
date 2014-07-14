require 'spec_helper'

describe Vcloud::Core::Login do
  let(:mock_env) { ENV }

  before(:each) do
    mock_fog_creds = ::Fog.credentials.clone
    @real_password = mock_fog_creds.delete(:vcloud_director_password)
    allow(::Fog).to receive(:credentials).and_return(mock_fog_creds)

    mock_env = ENV
    stub_const('ENV', mock_env)
  end

  describe "#token" do
    let(:token_regex) { /^.{44}$/ }
    let(:env_var_name) { 'FOG_VCLOUD_TOKEN' }

    context "environment variable VCLOUD_FOG_TOKEN not set" do
      it "should login and return a token" do
        mock_env.delete(env_var_name)
        expect(subject.token(@real_password)).to match(token_regex)
      end
    end

    context "environment variable VCLOUD_FOG_TOKEN is set" do
      let(:old_token) { 'mekmitasdigoat' }

      it "should login and return a token, ignoring the existing token" do
        mock_env[env_var_name] = old_token
        new_token = subject.token(@real_password)
        expect(new_token).to_not eq(old_token)
        expect(new_token).to match(token_regex)
      end
    end
  end
end
