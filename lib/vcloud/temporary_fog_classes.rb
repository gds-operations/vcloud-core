module Vcloud
  module Fog

    # FIXME: This is required because vCloud Core has a dependency
    # on vCloud Tools Tester. Once vCloud Tools Tester has been
    # updated to use the correct class, this can be removed.
    class ModelInterface < Vcloud::Core::Fog::ModelInterface
    end

  end
end
