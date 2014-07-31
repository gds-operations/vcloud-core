require 'fog'

module Vcloud
  module Core
    module Fog
      module Login
        class << self
          def token(pass)
            check_plaintext_pass
            token = get_token(pass)

            return token
          end

          def token_export(*args)
            return "export #{Vcloud::Fog::TOKEN_ENV_VAR_NAME}=#{token(*args)}"
          end

          private

          def check_plaintext_pass
            pass = Vcloud::Fog::fog_credentials_pass
            unless pass.nil? || pass.empty?
              raise "Found plaintext #{Vcloud::Fog::FOG_CREDS_PASS_NAME} entry. Please set it to an empty string"
            end
          end

          def get_token(pass)
            ENV.delete(Vcloud::Fog::TOKEN_ENV_VAR_NAME)
            vcloud = ::Fog::Compute::VcloudDirector.new({
              Vcloud::Fog::FOG_CREDS_PASS_NAME => pass,
            })

            return vcloud.vcloud_token
          end
        end
      end
    end
  end
end
