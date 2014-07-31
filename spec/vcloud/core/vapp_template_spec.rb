require 'spec_helper'

module Vcloud
  module Core
    describe VappTemplate do

      before(:each) do
        @id = 'vappTemplate-12345678-1234-1234-1234-000000234121'
        @mock_fog_interface = StubFogInterface.new
        allow(Vcloud::Core::Fog::ServiceInterface).to receive(:new).and_return(@mock_fog_interface)
      end

      context "Class public interface" do
        it { expect(VappTemplate).to respond_to(:get) }
      end

      context "Instance public interface" do
        subject { VappTemplate.new(@id) }
        it { should respond_to(:id) }
        it { should respond_to(:vcloud_attributes) }
        it { should respond_to(:name) }
        it { should respond_to(:href) }
      end

      context "#initialize" do

        it "should be constructable from just an id reference" do
          obj = VappTemplate.new(@id)
          expect(obj.class).to be(Vcloud::Core::VappTemplate)
        end

        it "should store the id specified" do
          obj = VappTemplate.new(@id)
          expect(obj.id).to eq(@id)
        end

        it "should raise error if id is not in correct format" do
          bogus_id = '12314124-ede5-4d07-bad5-000000111111'
          expect{ VappTemplate.new(bogus_id) }.to raise_error("vappTemplate id : #{bogus_id} is not in correct format" )
        end

      end


      context '#get' do

        it 'should raise a RuntimeError if there is no template' do
          q_results = [ ]
          mock_query = double(:query_runner)
          expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
          expect(mock_query).to receive(:run).
            with('vAppTemplate', :filter => "name==test_template;catalogName==test_catalog").
            and_return(q_results)
          expect { VappTemplate.get('test_template', 'test_catalog') }.
            to raise_error('Could not find template vApp')
        end

        it 'should raise an error if more than one template is returned' do
          q_results = [
            { :name => 'test_template',
              :href => "/vappTemplate-12345678-90ab-cdef-0123-4567890ab001" },
            { :name => 'test_template',
              :href => "/vappTemplate-12345678-90ab-cdef-0123-4567890ab002" },
          ]
          mock_query = double(:query_runner)
          expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
          expect(mock_query).to receive(:run).
            with('vAppTemplate', :filter => "name==test_template;catalogName==test_catalog").
            and_return(q_results)
          expect { VappTemplate.get('test_template', 'test_catalog') }.
            to raise_error('Template test_template is not unique in catalog test_catalog')
        end

        it 'should return a valid template object if it exists' do
          q_results = [
            { :name => 'test_template',
              :href => "/vappTemplate-12345678-90ab-cdef-0123-4567890abcde" }
          ]
          mock_query = double(:query)
          expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
          expect(mock_query).to receive(:run).
            with('vAppTemplate', :filter => "name==test_template;catalogName==test_catalog").
            and_return(q_results)
          test_template = VappTemplate.get('test_template', 'test_catalog')
          expect(test_template.id).to eq('vappTemplate-12345678-90ab-cdef-0123-4567890abcde')
        end

      end

    end
  end
end
