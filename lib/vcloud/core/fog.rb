require 'fog'
require 'vcloud/core/fog/fog_constants'
require 'vcloud/core/fog/login'
require 'vcloud/core/fog/service_interface'
require 'vcloud/core/fog/model_interface'

module Vcloud
  module Core
    module Fog
      TOKEN_ENV_VAR_NAME = 'FOG_VCLOUD_TOKEN'
      FOG_CREDS_PASS_NAME = :vcloud_director_password

      def self.check_credentials
        check_plaintext_pass
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

      private

      def self.check_plaintext_pass
        pass = fog_credentials_pass
        unless pass.nil? or pass.empty?
          raise "Found plaintext #{Vcloud::Core::Fog::FOG_CREDS_PASS_NAME} entry. Please set it to an empty string as storing passwords in plaintext is insecure. See http://gds-operations.github.io/vcloud-tools/usage/ for further information."
        end
      end

    end
  end
end

Vcloud::Core::Fog.check_credentials
