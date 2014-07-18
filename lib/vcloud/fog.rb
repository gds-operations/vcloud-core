require 'fog'
require 'vcloud/fog/content_types'
require 'vcloud/fog/login'
require 'vcloud/fog/relation'
require 'vcloud/fog/service_interface'
require 'vcloud/fog/model_interface'

module Vcloud
  module Fog
    TOKEN_ENV_VAR_NAME = 'FOG_VCLOUD_TOKEN'
    FOG_CREDS_PASS_NAME = :vcloud_director_password

    def self.check_credentials
      pass = fog_credentials_pass
      unless pass.nil? or pass.empty?
        warn <<EOF
[WARNING] Storing :vcloud_director_password in your plaintext FOG_RC file is
          insecure. Future releases of vcloud-core (and tools that depend on
          it) will prevent you from doing this. Please use vcloud-login to
          get a session token instead.
EOF
      end
    end

    def self.fog_credentials_pass
      begin
        pass = ::Fog.credentials[FOG_CREDS_PASS_NAME]
      rescue ::Fog::Errors::LoadError
        # Assume no password if Fog has been unable to load creds.
        # Suppresses a noisy error about missing credentials.
        pass = nil
      end

      pass
    end
  end
end

Vcloud::Fog.check_credentials
