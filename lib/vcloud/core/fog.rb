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

      # Logout an existing vCloud session, rendering the token unusable.
      # Requires a FOG_VCLOUD_TOKEN environment variable to be set.
      #
      # @return [Boolean] return true or raise an exception
      def self.logout
        unless ENV[TOKEN_ENV_VAR_NAME]
          raise "#{TOKEN_ENV_VAR_NAME} environment variable is not set"
        end

        fsi = Vcloud::Core::Fog::ServiceInterface.new
        fsi.logout

        return true
      end

      # Run any checks needed against the Fog credentials
      # currently only used to disallow plaintext passwords
      # in .fog files.
      #
      def self.check_credentials
        check_plaintext_pass
      end

      # Attempt to load the password from the fog credentials file
      #
      # @return [String, nil] The password if it could be loaded, 
      #                       else nil.
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

      # Check whether a plaintext password is in the Fog config
      # file
      #
      # @return [void]
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
