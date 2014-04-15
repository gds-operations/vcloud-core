# VCloud Core

VCloud Core is a gem that supports automatated provisioning of VMWare vCloud Director. It uses Fog under the hood. Primarily developed to support [VCloud Walker](https://github.com/alphagov/vcloud-walker) and [VCloud Tools](https://github.com/alphagov/vcloud-tools).

VCloud Core includes VCloud Query and a command-line wrapper for VCloud Query.

## Installation

Add this line to your application's Gemfile:

    gem 'vcloud-core'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vcloud-core

## VCloud Query

### Get results from the vCloud Query API

VCloud Query is a light wrapper around the vCloud Query API.

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

    # Get a list of all queriable types (left column)
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

## Testing

Default target: `bundle exec rake`
Runs the unit tests and feature tests.

* Unit tests only: `bundle exec rake spec`
* Feature tests only: `bundle exec rake feature`
* Integration tests: `bundle exec rake integration`

### setting up and describing your environment for test runs

You need access to a suitable vCloud Director organization to run the integration tests - it also needs some basic
configuration: an Edge Gateway, and a routed network.
It is not necessarily safe to run them against an existing environment, unless care is taken with the entities being
tested.

A number of ENV vars specifying items under test in the environment need to be set for the tests to run successfully.

- `VCLOUD_EDGE_GATEWAY`: _name of edge gateway under test_
- `VCLOUD_NETWORK1_ID`: _Id of network under test_
- `VCLOUD_PROVIDER_NETWORK_ID`: _Id of the uplink network (or external network) of the VCLOUD_EDGE_GATEWAY under test_

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
