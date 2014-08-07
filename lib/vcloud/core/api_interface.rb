module Vcloud
  module Core

    # Public interface to allow direct access to the API
    # if functionality does not exist in Core
    class ApiInterface

      def initialize
        @fog_service_interface = Vcloud::Core::Fog::ServiceInterface.new
        @fog_model_interface = Vcloud::Core::Fog::ModelInterface.new
      end

      def get_vapp_by_name_and_vdc_name(name, vdc_name)
        @fog_service_interface.get_vapp_by_name_and_vdc_name(name, vdc_name)
      end

      def get_vapp(id)
        @fog_service_interface.get_vapp(id)
      end

      def delete_vapp(id)
        @fog_service_interface.delete_vapp(id)
      end

      def delete_network(id)
        @fog_service_interface.delete_network(id)
      end

      def current_organization
        @fog_model_interface.current_organization
      end

    end
  end
end
