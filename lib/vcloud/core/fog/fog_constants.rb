module Vcloud
  module Core
    module Fog

      # Private helper constants for use with the vCloud API.
      #
      # @api private
      module ContentTypes
        ORG = 'application/vnd.vmware.vcloud.org+xml'
        VDC = 'application/vnd.vmware.vcloud.vdc+xml'
        NETWORK = 'application/vnd.vmware.vcloud.network+xml'
        METADATA = 'application/vnd.vmware.vcloud.metadata.value+xml'
      end

      # Private helper constants for use with the vCloud API.
      #
      # @api private
      module MetadataValueType
        String = 'MetadataStringValue'
        Number = 'MetadataNumberValue'
        DateTime = 'MetadataDateTimeValue'
        Boolean = 'MetadataBooleanValue'
      end

      # Private helper constants for use with the vCloud API.
      #
      # @api private
      module RELATION
        PARENT = 'up'
        CHILD = 'down'
      end

    end
  end
end
