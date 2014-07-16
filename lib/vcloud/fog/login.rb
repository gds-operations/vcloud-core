require 'fog'

module Vcloud
  module Fog
    module Login
      TOKEN_ENV_VAR_NAME = 'FOG_VCLOUD_TOKEN'
      FOG_CREDS_PASS_NAME = :vcloud_director_password

      def self.token(pass)
        check_plaintext_pass
        token = get_token(pass)

        return token
      end

      def self.token_export(*args)
        return "export #{TOKEN_ENV_VAR_NAME}=#{token(*args)}"
      end

      private

      def self.check_plaintext_pass
        pass = ::Fog.credentials[FOG_CREDS_PASS_NAME]
        unless pass.nil? || pass.empty?
          raise "Found plaintext #{FOG_CREDS_PASS_NAME} entry. Please set it to an empty string"
        end
      end

      def self.get_token(pass)
        ENV.delete(TOKEN_ENV_VAR_NAME)
        vcloud = ::Fog::Compute::VcloudDirector.new({
          FOG_CREDS_PASS_NAME => pass,
        })

        return vcloud.vcloud_token
      end
    end
  end
end
