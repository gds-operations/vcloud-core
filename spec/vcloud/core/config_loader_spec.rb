require 'spec_helper'

module Vcloud
  module Core
    describe ConfigLoader do

      before(:all) do
        @data_dir = File.join(File.dirname(__FILE__), "/data")
      end

      describe 'basic config loading' do
        it "should create a valid hash when input is JSON" do
          input_file = "#{@data_dir}/working.json"
          loader = ConfigLoader.new
          actual_config = loader.load_config(input_file)
          valid_config.should eq(actual_config)
        end

        it "should create a valid hash when input is YAML" do
          input_file = "#{@data_dir}/working.yaml"
          loader = ConfigLoader.new
          actual_config = loader.load_config(input_file)
          valid_config.should eq(actual_config)
        end

        it "should create a valid hash when input is YAML with anchor defaults" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new
          actual_config = loader.load_config(input_file)
          valid_config['vapps'].should eq(actual_config['vapps'])
        end
      end

      describe 'config loading with variable interpolation' do
        it "should create a valid hash when input is YAML with variable file" do
          input_file = "#{@data_dir}/working_template.yaml"
          vars_file = "#{@data_dir}/working_variables.yaml"
          loader = ConfigLoader.new
          actual_config = loader.load_config(input_file, nil, vars_file)
          valid_config.should eq(actual_config)
        end
      end

      describe 'config loading with schema validation' do
        it "should validate correctly against a schema" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new
          schema = vapp_config_schema
          actual_config = loader.load_config(input_file, schema)
          valid_config['vapps'].should eq(actual_config['vapps'])
        end

        it "should raise an error if checked against an invalid schema" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new
          Vcloud::Core.logger.should_receive(:fatal).with("vapps: is not a hash")
          expect { loader.load_config(input_file, invalid_schema) }.
            to raise_error('Supplied configuration does not match supplied schema')
        end
      end

      def vapp_config_schema
        {
          type: 'hash',
          allowed_empty: false,
          permit_unknown_parameters: true,
          internals: {
            vapps: {
              type: 'array',
              required: false,
              allowed_empty: true,
            },
          }
        }
      end

      def invalid_schema
        {
          type: Hash,
          permit_unknown_parameters: true,
          internals: {
            vapps: { type: Hash },
          }
        }
      end

      def valid_config
        {
          :vapps=>[{
            :name=>"vapp-vcloud-tools-tests",
            :vdc_name=>"VDC_NAME",
            :catalog=>"CATALOG_NAME",
            :vapp_template=>"VAPP_TEMPLATE",
            :vm=>{
              :hardware_config=>{:memory=>"4096", :cpu=>"2"},
              :extra_disks=>[{:size=>"8192"}],
              :network_connections=>[{
                :name=>"Default",
                :ip_address=>"192.168.2.10"
                },
                {
                :name=>"NetworkTest2",
                :ip_address=>"192.168.1.10"
              }],
              :bootstrap=>{
                :script_path=>"spec/data/basic_preamble_test.erb",
                :vars=>{:message=>"hello world"}
              },
              :metadata=>{}
            }
          }]
        }
      end
    end
  end
end
