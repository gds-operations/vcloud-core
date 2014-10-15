module Vcloud
  module Core
    module ComputeMetadata

        # Returns the metadata for a compute resource
        #
        # @param id [String] The ID of the vApp or VM to retrieve metadata for
        # @return [Hash] Metadata keys/values
        def get_metadata id
          vcloud_compute_metadata =  Vcloud::Core::Fog::ServiceInterface.new.get_vapp_metadata(id)
          MetadataHelper.extract_metadata(vcloud_compute_metadata[:MetadataEntry])
        end

    end
  end
end

