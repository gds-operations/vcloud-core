module Vcloud
  module Core
    module Fog
      module ContentTypes
        ORG = 'application/vnd.vmware.vcloud.org+xml'
        VDC = 'application/vnd.vmware.vcloud.vdc+xml'
        NETWORK = 'application/vnd.vmware.vcloud.network+xml'
        METADATA = 'application/vnd.vmware.vcloud.metadata.value+xml'
      end

      module MetadataValueType
        String = 'MetadataStringValue'
        Number = 'MetadataNumberValue'
        DateTime = 'MetadataDateTimeValue'
        Boolean = 'MetadataBooleanValue'
      end

    end
  end
end
