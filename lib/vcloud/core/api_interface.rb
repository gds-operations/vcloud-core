module Vcloud
  module Core

    # Public interface to allow direct access to the API
    # if functionality does not exist in Core
    class ApiInterface

      # Private interface to Fog service layer to allow direct access to Fog
      # for functionality not exposed elsewhere in Vcloud::Core.
      #
      # @api private
      def fog_service_interface
        @fog_service_interface ||= Vcloud::Core::Fog::ServiceInterface.new
      end

      # Private interface to Fog model layer to allow direct access to Fog for
      # functionality not exposed elsewhere in Vcloud::Core.
      #
      # @api private
      def fog_model_interface
        @fog_model_interface ||= Vcloud::Core::Fog::ModelInterface.new
      end

      # Get a vApp by name and vdc_name
      #
      # @param name [String] Name of the vApp
      # @param vdc_name [String] Name of the vDC
      # @return [String] Response body describing the vApp
      def get_vapp_by_name_and_vdc_name(name, vdc_name)
        fog_service_interface.get_vapp_by_name_and_vdc_name(name, vdc_name)
      end

      # Get a vApp by id
      #
      # @param  id [String] ID of the vApp to get
      # @return [String] Response body describing the vApp
      def get_vapp(id)
        fog_service_interface.get_vapp(id)
      end

      # Delete a vApp by id
      #
      # @param id [String] ID of the vApp to delete
      # @return [void]
      def delete_vapp(id)
        fog_service_interface.delete_vapp(id)
      end

      # Delete a network by id
      #
      # @param id [String] ID of the network to delete
      # @return [void]
      def delete_network(id)
        fog_service_interface.delete_network(id)
      end

      # Returns a Fog::Compute::VcloudDirector::Organization instance representing
      # the current organization
      #
      # @return [Fog::Compute::VcloudDirector::Organization]
      def current_organization
        fog_model_interface.current_organization
      end

    end
  end
end
