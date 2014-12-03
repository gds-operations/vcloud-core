require 'spec_helper'

describe Vcloud::Core::Fog do
  describe "#logout" do
    let(:subject) { Vcloud::Core::Fog.logout }

    let(:envvar_token) { 'FOG_VCLOUD_TOKEN' }
    let(:envvar_password) { 'API_PASSWORD' }

    context "with a valid token" do
      before(:each) do
        @real_password = ENV[envvar_password]
        unless @real_password
          pending "Password not available from environment variable #{envvar_password}"
        end

        stub_const('ENV', {})
        temp_token = Vcloud::Core::Fog::Login.token(@real_password)
        ENV[envvar_token] = temp_token
      end

      it "should invalidate a previously working session" do
        fsi = Vcloud::Core::Fog::ServiceInterface.new
        expect(fsi.session).to include(:user, :org)

        expect(subject).to eq(true)
        # logout appears to sometimes be slightly asynchronous and doesn't
        # provide a task that we can monitor the progress of.
        sleep(1)

        fsi = Vcloud::Core::Fog::ServiceInterface.new
        expect{ fsi.session }.to raise_error(
          Fog::Compute::VcloudDirector::Forbidden, "Access is forbidden"
        )
      end
    end

    context "with an invalid token" do
      before(:each) do
        stub_const('ENV', { envvar_token => 'invalid' })
      end

      it "should raise an exception from Fog" do
        expect{ subject }.to raise_error(
          Fog::Compute::VcloudDirector::Forbidden, "Access is forbidden"
        )
      end
    end
  end
end
