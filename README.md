# vCloud Core

vCloud Core is a gem that supports automatated provisioning of VMWare vCloud Director. It uses Fog under the hood. Primarily developed to support [vCloud Walker](https://github.com/gds-operations/vcloud-walker) and [vCloud Tools](https://github.com/gds-operations/vcloud-tools).

vCloud Core includes vCloud Query and a command-line wrapper for vCloud Query.

## Installation

Add this line to your application's Gemfile:

    gem 'vcloud-core'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vcloud-core

## Credentials

Please see the [vcloud-tools usage documentation](http://gds-operations.github.io/vcloud-tools/usage/).

## vCloud Query

### Get results from the vCloud Query API

vCloud Query is a light wrapper around the vCloud Query API.

Any, or all, records of a particular 'type' can be returned. These types map to 
entities in the vCloud system itself, eg: 'vm', 'vApp', 'orgVdc', 'edgeGateway'.

Filters can be applied, using a simple query syntax. See below for basic usage and
examples.

Run with no arguments, it outputs a list of potential entity types to query, along
with the potential record types to display (default 'records')

#### Usage:

    vcloud-query [options] [queriable type]

    where [queriable type] maps to a vcloud entity type, eg: vApp, vm, orgVdc

#### Examples:

NB: examples assume FOG_CREDENTIAL or FOG_VCLOUD_TOKEN has been set accordingly.

    # Get a list of vApps, in YAML
    vcloud-query -o yaml vApp

    # Get general usage info
    vcloud-query --help

    # Get a list of all queriable entity types
    vcloud-query

    # Get all VMs with VMware Tools less than 9282, that are not a vApp Template:
    vcloud-query --filter 'vmToolsVersion=lt=9282;isVAppTemplate==false' vm

#### Supports:

* Returning a list of queriable types (eg vm, vApp, edgeGateway) from the API
* Displaying all vCloud entities of a given type
* Filtering the results of the query based on common parameters such as:
  * entity name
  * metadata values
  * key entity parameters
* Limiting the output to certain fields (eg: name, vmToolsVersion)
* Returning results in TSV, CSV, and YAML

#### Query Syntax:

Summary of filter query syntax:

    attribute==value                      # == to check equality
    attribute!=value                      # != to check inequality
    attribute=lt=value                    # =lt= less than (=le= for <=)
    attribute=gt=value                    # =gt= greater than (=ge= for >=)
    attribute==value;attribute2==value2   # ; == AND
    attribute==value,attribute2==value2   # , == OR

Parentheses can be used to group sub-queries.

**Do not use spaces in the query**

Entity metadata queries have their own subsyntax incorporating the value types:

    metadata:key1==STRING:value1
    metadata:key1=le=NUMBER:15
    metadata:key1=gt=DATETIME:2012-06-18T12:00:00-05:00

See http://pubs.vmware.com/vcd-51/topic/com.vmware.vcloud.api.doc_51/GUID-4FD71B6D-6797-4B8E-B9F0-618F4ACBEFAC.html for details.

## The vCloud API

vCloud Tools currently use version 5.1 of the [vCloud API](http://pubs.vmware.com/vcd-51/index.jsp?topic=%2Fcom.vmware.vcloud.api.doc_51%2FGUID-F4BF9D5D-EF66-4D36-A6EB-2086703F6E37.html). Version 5.5 may work but is not currently supported. You should be able to access the 5.1 API in a 5.5 environment, and this *is* currently supported.

The default version is defined in [Fog](https://github.com/fog/fog/blob/244a049918604eadbcebd3a8eaaf433424fe4617/lib/fog/vcloud_director/compute.rb#L32).

If you want to be sure you are pinning to 5.1, or use 5.5, you can set the API version to use in your fog file, e.g.

`vcloud_director_api_version: 5.1`

## Working with Independent Disks

vCloud Core now supports the management of Independent Disks -- block devices
stored and managed separately from the VMs they are attached to. We have
noticed that this bring some limitations/caveats into play that API users
should be aware of:

* It is not possible to move the VM from one Storage Profile to another with
  Vm#update_storage_profile if an Independent Disk is attached. This appears to
  be a limitation in vCloud Director itself. To work around this, detach the
  disks before updating, and reattach afterwards.

* It is not possible to add additional *local* disks via Vm#add_extra_disks
  when Independent Disks are attached to a VM. This appears to be a limitation with
  Fog, as the vCD UI permits it. See https://github.com/fog/fog/issues/3179
  for progress on this issue.

* Extreme care should be taken when detaching Independent Disks from a VM, as
  vCloud Director will detach them without warning from running VMs, and hence
  with no notification to the running OS. It is recommended to simply use them for
  persistence across VM delete/recreate operations.

## Debugging

`export EXCON_DEBUG=true` - this will print out the API requests and responses.

## Testing

Run the default suite of tests (e.g. lint, unit, features):

    bundle exec rake

There are also integration tests. These are slower and require a real environment.
See the [vCloud Tools website](http://gds-operations.github.io/vcloud-tools/testing/) for details of how to set up and run the integration tests.

The parameters required to run the vCloud Core integration tests are:

````
default: # This is the fog credential that refers to your testing environment, e.g. `test_credential`
  vdc_1_name: # The name of a VDC
  catalog: # A catalog
  vapp_template: # A vApp Template within that catalog
  network_1: # The name of the primary network
  network_1_ip: # The IP address of the primary network
````
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
