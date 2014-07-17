require 'fog'

module Vcloud
  module Fog
    module Login
      TOKEN_ENV_VAR_NAME = 'FOG_VCLOUD_TOKEN'
      FOG_CREDS_PASS_NAME = :vcloud_director_password

      class << self
        def token(pass)
          check_plaintext_pass
          token = get_token(pass)

          return token
        end

        def token_export(*args)
          return "export #{TOKEN_ENV_VAR_NAME}=#{token(*args)}"
        end

        private

        def check_plaintext_pass
          begin
            pass = ::Fog.credentials[FOG_CREDS_PASS_NAME]
          rescue ::Fog::Errors::LoadError
            # Assume no password if Fog has been unable to load creds.
            # Suppresses a noisy error about missing credentials. We get a
            # more succinct error in get_token()
            return
          end

          unless pass.nil? || pass.empty?
            raise "Found plaintext #{FOG_CREDS_PASS_NAME} entry. Please set it to an empty string"
          end
        end

        def get_token(pass)
          ENV.delete(TOKEN_ENV_VAR_NAME)
          vcloud = ::Fog::Compute::VcloudDirector.new({
            FOG_CREDS_PASS_NAME => pass,
          })

          return vcloud.vcloud_token
        end
      end
    end
  end
end
