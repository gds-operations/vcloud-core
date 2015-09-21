require 'spec_helper'

describe Vcloud::Core::Fog::Login do
  describe "#token" do
    context "unable to load credentials" do
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

      it "should raise an exception succinctly listing the missing credentials" do
        # This test is known to fail with a TypeError due to a bug in Ruby 1.9.3 that
        # has since been fixed. See https://github.com/gds-operations/vcloud-core/pull/100
        expect { ::Fog.credentials['doesnotexist'] }.to raise_error(
          Fog::Errors::LoadError,
          /^Missing Credentials\n/
        )
      end

      it "should raise an exception succinctly listing the missing credentials when a token is supplied" do
        pending "FIXME: Test broken by https://github.com/fog/fog-core/commit/08df3056420fa509079704e9e2ac2dd3a04b987e#diff-ff84bd2420c81ca6f03e176dbc1fbdf7L19\n" \
          "Remove 'pending' once https://github.com/fog/fog-core/pull/97 is in a released version of Fog"
        expect { subject.token('supersekret') }.to raise_error(
          ArgumentError,
          /^Missing required arguments: vcloud_director_.*$/
        )
      end
    end

    context "fog credentials without password" do
      let(:token_length) { 32 }
      let(:envvar_token) { 'FOG_VCLOUD_TOKEN' }
      let(:envvar_password) { 'API_PASSWORD' }

      before(:each) do
        @temp_token = nil
        @real_password = ENV[envvar_password]
        stub_const('ENV', {})
      end

      after(:each) do
        stub_const('ENV', { envvar_token => @temp_token })
        fsi = Vcloud::Core::Fog::ServiceInterface.new
        fsi.logout
      end

      context "environment variable VCLOUD_FOG_TOKEN not set" do
        it "should login and return a token" do
          unless @real_password
            pending "Password not available from environment variable #{envvar_password}"
          end

          expect(ENV).not_to have_key(envvar_token)
          @temp_token = subject.token(@real_password)
          expect(@temp_token.size).to eq(token_length)
        end
      end

      context "environment variable VCLOUD_FOG_TOKEN is set" do
        let(:old_token) { 'mekmitasdigoat' }

        it "should login and return a token, ignoring the existing token" do
          unless @real_password
            pending "Password not available from environment variable #{envvar_password}"
          end

          ENV[envvar_token] = old_token
          @temp_token = subject.token(@real_password)
          expect(@temp_token).to_not eq(old_token)
          expect(@temp_token.size).to eq(token_length)
        end
      end
    end
  end
end
