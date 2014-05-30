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
          expect(valid_config).to eq(actual_config)
        end

        it "should create a valid hash when input is YAML" do
          input_file = "#{@data_dir}/working.yaml"
          loader = ConfigLoader.new
          actual_config = loader.load_config(input_file)
          expect(valid_config).to eq(actual_config)
        end

        it "should create a valid hash when input is YAML with anchor defaults" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new
          actual_config = loader.load_config(input_file)
          expect(valid_config['vapps']).to eq(actual_config['vapps'])
        end
      end

      describe 'config loading with variable interpolation' do
        it "should create a valid hash when input is YAML with variable file" do
          input_file = "#{@data_dir}/working_template.yaml"
          vars_file = "#{@data_dir}/working_variables.yaml"
          loader = ConfigLoader.new
          actual_config = loader.load_config(input_file, nil, vars_file)
          expect(valid_config).to eq(actual_config)
        end
      end

      describe 'config loading with schema validation' do
        it "should validate correctly against a schema" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new
          schema = vapp_config_schema
          actual_config = loader.load_config(input_file, schema)
          expect(valid_config['vapps']).to eq(actual_config['vapps'])
        end

        it "should raise an error if checked against an invalid schema" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new
          expect(Vcloud::Core.logger).to receive(:fatal).with("vapps: is not a hash")
          expect { loader.load_config(input_file, invalid_schema) }.
            to raise_error('Supplied configuration does not match supplied schema')
        end

        it "should not log warnings if there are none" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new

          expect(Vcloud::Core.logger).not_to receive(:warn)
          loader.load_config(input_file, vapp_config_schema)
        end

        it "should log warnings if checked against a deprecated schema" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new

          expect(Vcloud::Core.logger).to receive(:warn).with("vapps: is deprecated by 'vapps_new'")
          loader.load_config(input_file, deprecated_schema)
        end

        it "should log warning before raising error against an invalid and deprecated schema" do
          input_file = "#{@data_dir}/working_with_defaults.yaml"
          loader = ConfigLoader.new

          expect(Vcloud::Core.logger).to receive(:warn).with("vapps: is deprecated by 'vapps_new'")
          expect(Vcloud::Core.logger).to receive(:fatal).with("vapps: is not a hash")
          expect { loader.load_config(input_file, invalid_and_deprecated_schema) }.
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

      def invalid_and_deprecated_schema
        {
          type: 'hash',
          permit_unknown_parameters: true,
          internals: {
            vapps: { type: Hash, deprecated_by: 'vapps_new' },
            vapps_new: { type: 'array' },
          }
        }
      end

      def deprecated_schema
        {
          type: 'hash',
          permit_unknown_parameters: true,
          internals: {
            vapps: { type: 'array', deprecated_by: 'vapps_new' },
            vapps_new: { type: 'array' },
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
