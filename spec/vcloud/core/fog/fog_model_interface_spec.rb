require 'spec_helper'

describe Vcloud::Core::Fog::ModelInterface do

  it "should retrive logged in organization" do
    vm_href, vdc_href = 'https://vmware.net/vapp/vm-1', 'vdc/vdc-1'
    vm = double(:vm, :href => vm_href)
    vdc = double(:vdc1,
                 :id => 'vdc-1',
                 :href => vdc_href,
                 :vapps => double(:vapps, :get_by_name => double(:vapp, :name => 'vapp-1', :vms => [vm])))
    org = double(:hr, :name => 'HR ORG', :vdcs => [vdc])

    vcloud = double(:mock_vcloud, :org_name => 'HR', :organizations => double(:orgs, :get_by_name => org))
    expect(vcloud).to receive(:get_vms_in_lease_from_query).with({:filter => "href==#{vm_href}"}).and_return(
        double(
            :vm_query_record,
            :body => {:VMRecord => [{:href => vm_href, :containerName => 'vapp-1', :vdc => vdc_href}]}
        )
    )
    expect(Fog::Compute::VcloudDirector).to receive(:new).and_return(vcloud)

    expect(Vcloud::Core::Fog::ModelInterface.new.get_vm_by_href(vm_href)).to eq(vm)
  end
end
