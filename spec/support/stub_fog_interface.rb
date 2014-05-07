require 'ostruct'

class StubFogInterface

  def name
    'Test vDC 1'
  end

  def vdc_object_by_name(vdc_name)
    vdc = OpenStruct.new
    vdc.name = vdc_name
    vdc
  end

  def template
    { :href => '/vappTemplate-12345678-90ab-cdef-0123-4567890abcde' }
  end

  def find_networks(_network_names, _vdc_name)
    [{
      :name => 'org-vdc-1-net-1',
      :href => '/org-vdc-1-net-1-id',
    }]
  end

  def get_vapp(id)
    {
      :name => 'test-vapp-1',
      :href => "/#{id}",
    }
  end

  def get_edge_gateway(id)
    { 
      :name => 'test-edgegw-1',
      :href => "/#{id}",
    }
  end

  def vdc(_name)
    { }
  end

  def post_instantiate_vapp_template(_vdc, _template, _name, _params)
    {
      :href => '/test-vapp-1-id',
      :Children => {
        :Vm => ['bogus vm data']
      }
    }
  end

  def get_vapp_by_vdc_and_name
    { }
  end

  def template(_catalog_name, _name)
    { :href => '/vappTemplate-12345678-90ab-cdef-0123-4567890abcde' }
  end


end
