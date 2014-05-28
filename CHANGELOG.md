## 0.5.0 (UNRELEASED)

Features:

  - `vcloud-query --version` now only returns the version string and no
    usage information.

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
