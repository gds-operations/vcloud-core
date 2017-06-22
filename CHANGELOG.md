## 2.1.0 (2017-06-22)

  - Removed support for Ruby older than 2.2.2
  - Added support for Ruby 2.3.0 and 2.4.0
  - Various bug fixes
  - Updated version of Fog (1.40)

## 2.0.1 (2017-06-09)

  - Bug fix related to the `last_comment` method being removed in Rake
  - Pinned nokogiri to work with Ruby 2.0
  - Upgraded rspec
  - Various bug fixes

## 2.0.0 (2015-12-24)

  - Remove support for Ruby 1.9.3, which is now end-of-life.
  - Update version of fog to work around a bug in fog 1.35.0
  - Minor fixes to tests

## 1.2.0 (2015-09-10)

Bugfixes:

  - Upgrade to Fog version 1.34.0 to support multiple peer and local subnets
    with vSE IPSEC VPN

## 1.1.0 (2015-06-30)

Features:

  - Add the ability to set the MAC address of a VM

Bugfixes:

  - Add an explicit `require 'json'` to the ConfigLoader

## 1.0.2 (2015-02-24)

Documentation:

  - `DEBUG` environment variable removed from the README as this is no longer
    supported
  - Copyright notice updated to reflect the copyright's correct legal owner
    (Crown Copyright)

Bugfixes:

  - Test namespaces and indentation made consistent
  - Fog dependency is now pinned to version 1.x to prevent breakage on release
    of a future version 2
  - Explictly require Fog Core version 1.27.4 to prevent this error:

      undefined method `redisplay_progressbar' for Fog::Formatador:Class

## 1.0.1 (2015-01-29)

Documentation:

    - Update integration test details in README
    - Update Gem ownership details

Fixes:

    - Tighten dependency on vcloud-tools-tester
    - Refactored test namespacing

## 1.0.0 (2015-01-22)

  - Release 1.0.0 since the public API is now stable

## 0.16.1 (2015-01-15)

Bugfixes:

  - Pin Mustache dependency to 0.99.x to maintain support for Ruby 1.9.3

## 0.16.0 (2014-12-03)

Features:

  - New `vcloud-logout` command line utility to revoke session tokens.
  - New `Vcloud::Core::Fog.logout` method to revoke session tokens.

## 0.15.0 (2014-11-26)

Features:

  - New method IndependentDisk#destroy to delete an independent disk.

Bugfixes:

  - Upgrade to Fog version 1.25.0 to support vCloud usernames containing more than
    one `@` symbol.

## 0.14.0 (2014-11-10)

API changes:

  - Automatic pagination of `Vcloud::QueryRunner` results can now be
    overridden with `page` and `pageSize` options.

Documentation:

  - Documented all the public methods in vcloud-core to comply with semver.org recommendations.

## 0.13.0 (2014-10-13)

Features:

  - Upgrade Fog dependency to version 1.24.0, which ensures that the `FOG_CREDENTIAL`
    environment variable matches the information stored against any vCloud session referred
    to by `FOG_VCLOUD_TOKEN`.

## 0.12.0 (2014-10-03)

Features:

  - Adds custom fields support to vApps. Thanks @geriBatai
  - Adds IndependentDisk entity class, for creation and discovery of Independent Disks. Thanks @mikepea
  - Adds methods to attach and detach IndependentDisk objects to/from an existing VM. Thanks @mikepea
  - Add Vapp.get_by_child_vm_id method, to find a vApp by its child VM id. Thanks @mikepea

## 0.11.0 (2014-09-11)

Features:

  - As deprecated in 0.7.0, it is now impossible to specify a plaintext
    password in a FOG_RC file. Please use tokens via vcloud-login as per
    the documentation: http://gds-operations.github.io/vcloud-tools/usage/

## 0.10.0 (2014-08-11)

API changes:

  - Removes the temporary files used for transitioning vCloud Tools Tester to use the new API.

## 0.9.0 (2014-08-08)

API changes:

  - Change name of method that returns the VMs in a vApp via the API, from
    `fog_vms` to `vms`.
    This change is not backwards-compatible.

## 0.8.0 (2014-08-07)

API changes:

  - Create new `Vcloud::Core::ApiInterface` that delegates calls to the fog
    service interface and model interface, so that gems that depend on
    vCloud Core do not need to know about the inner workings of fog, or
    about fog at all.
  - Move fog classes into Core. This API change is not backwards-compatible.
  - Mark the fog classes `@api private` to clarify that they do not form
    part of the public API.

## 0.7.0 (2014-07-28)

Features:

  - New vcloud-login tool for fetching session tokens without the need to
    store your password in a plaintext FOG_RC file.

Deprecated:

  - Deprecate the use of :vcloud_director_password in a plaintext FOG_RC
    file. A warning will be printed to STDERR at load time. Please use
    vcloud-login instead.

## 0.6.0 (2014-07-14)

API changes:

  - The minimum required Ruby version is now 1.9.3.
  - The interface to `Vcloud::Core::Vm#configure_guest_customization_section`
    has changed and much of its logic has moved to the vCloud Launcher gem.
    Thanks to @bazbremner for this contribution.

## 0.5.0 (2014-05-30)

Features:

  - `vcloud-query --version` now only returns the version string and no
    usage information.
  - Support 'pool' mode for VM IP address allocation. Thanks @geriBatai.

## 0.4.0 (2014-05-23)

Features:

  - Add a 'warnings' variable/method to ConfigValidator.
  - Support simple parameter deprecations in ConfigValidator.
  - Log schema warnings encountered in ConfigLoader.

API changes:

  - Breaking changes to the order and name of arguments for VappTemplate#get
  - Remove unused methods Vcloud::Fog::ServiceInterface#get_catalog and
    Vcloud::Fog::ServiceInterface#get_catalog_item, plus associated
    Vcloud::Fog::ContentTypes constants.
  - Restrict variable scope available to preamble ERB templates so that they
    cannot access or modify the Vm object.

## 0.3.0 (2014-05-13)

Features:

  - Switch from deprecated Fog get_network request to get_network_complete
  - Breaking change to OrgVdcNetwork#vcloud_attributes due to Fog deprecation fix
  - Updated vm/vApp logging levels to make use of quiet/normal/verbose operation

## 0.2.0 (2014-05-06)

Features:

  - Breaking changes to move Vcloud::Query and Vcloud::QueryRunner under Vcloud::Core namespace

## 0.1.0 (2014-05-02)

Feature:

  - Allow config files to be rendered from [Mustache](http://mustache.github.io/)
    templates so that common configs can be re-used across environments with
    differences represented as variables.

## 0.0.13 (2014-04-30)

Feature:

  - Remove support for Query API formats - we only ever use 'record' format.

## 0.0.12 (2014-04-22)

Bugfix:

  - move to require fog v1.22 to allow for issue with progress task bar exposed with upgrade to vCloud Director 5.5

## 0.0.11 (2014-04-01)

Features:

  - move to require fog v1.21 to allow use of vcloud_token via ENV

## 0.0.10 (2014-03-17)

Features:

  - separates out the query runner tool that interfaces with fog from the CLI tool

Deprecated:

  - Vcloud::Query.get_all_results should no longer be used - use Vcloud::QueryRunner.run instead

## 0.0.9 (2014-03-10)

Features:

  - adds a configuration loader and a configuration validator

## 0.0.8 (2014-03-04)

Bugfix:

  - missing VM bootstrap->vars section would throw NilClass error

## 0.0.7 (2014-03-03)

Bugfixes:

  - vAppTemplate not retrieved if ISO exists with similar name [#66758184]

## 0.0.6 (2014-02-13)

Features:

  - adds EdgeGateway.interfaces for returning array of EdgeGatewayInterface objects
    associated with the EdgeGateway
  - adds EdgeGatewayInterface class, representing a vCloud GatewayInterfaceType

## 0.0.5 (2014-01-29)

Features:

  - adds support for retrieving gateway interface by id

## 0.0.4 (2014-01-23)

Features:

  - adds ability to update Edge Gateway configuration

## 0.0.1 (2014-01-17)

  - First release of gem
