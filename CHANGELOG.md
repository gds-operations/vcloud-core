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
