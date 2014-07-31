module Vcloud
  module Core
    class VappTemplate

      attr_reader :id

      def initialize(id)
        unless id =~ /^#{self.class.id_prefix}-[-0-9a-f]+$/
          raise "#{self.class.id_prefix} id : #{id} is not in correct format"
        end
        @id = id
      end

      def vcloud_attributes
        Vcloud::Core::Fog::ServiceInterface.new.get_vapp_template(id)
      end

      def href
        vcloud_attributes[:href]
      end

      def name
        vcloud_attributes[:name]
      end

      def self.get_ids_by_name_and_catalog name, catalog_name
        raise "provide Catalog and vAppTemplate name" unless name && catalog_name
        q = Vcloud::Core::QueryRunner.new
        query_results = q.run('vAppTemplate', :filter => "name==#{name};catalogName==#{catalog_name}")
        raise "Error retreiving #{q.type} query '#{q.filter}'" unless query_results
        query_results.collect do |record|
          record[:href].split('/').last if record.key?(:href)
        end
      end

      def self.get vapp_template_name, catalog_name
        ids = self.get_ids_by_name_and_catalog(vapp_template_name, catalog_name)
        raise 'Could not find template vApp' if ids.size == 0
        if ids.size > 1
          raise "Template #{vapp_template_name} is not unique in catalog #{catalog_name}"
        end
        return self.new(ids.first)
      end

      def self.id_prefix
        'vappTemplate'
      end

    end
  end
end
