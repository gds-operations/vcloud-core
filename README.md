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

## Credentials

vCloud Core is based around [fog](http://fog.io/). To use it you'll need to give it
credentials that allow it to talk to a vCloud Director environment.

1. Create a '.fog' file in your home directory.

  For example:

      test_credentials:
        vcloud_director_host: 'host.api.example.com'
        vcloud_director_username: 'username@org_name'
        vcloud_director_password: ''

2. Obtain a session token. First, curl the API:

        curl -D- -d '' \
            -H 'Accept: application/*+xml;version=5.1' -u '<username>@<org_name>' \
            https://<host.api.example.com>/api/sessions

  This will prompt for your password.

  From the headers returned, the value of the `x-vcloud-authorization` header is your
  session token, and this will be valid for 30 minutes idle - any activity will extend
  its life by another 30 minutes.

3. Specify your credentials and session token at the beginning of the command. For example:

        FOG_CREDENTIAL=test_credentials \
            FOG_VCLOUD_TOKEN=AAAABBBBBCCCCCCDDDDDDEEEEEEFFFFF= \
            vcloud-query

  You may find it easier to export one or both of the values as environment variables.

  **NB** It is also possible to sidestep the need for the session token by saving your
  password in the fog file. This is **not recommended**.


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

## Debugging

`export EXCON_DEBUG=true` - this will print out the API requests and responses.

`export DEBUG=true` - this will show you the stack trace when there is an exception instead of just the message.

## Testing

Run the default suite of tests (e.g. lint, unit, features):

    bundle exec rake

Run the integration tests (slower and requires a real environment):

    bundle exec rake integration

You need access to a suitable vCloud Director organization to run the
integration tests. See the [integration tests README](/spec/integration/README.md) for
further details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
