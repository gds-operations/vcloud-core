#!/bin/bash -x
set -e

git clean -ffdx

# We wish to force using a version of ruby installed with rbenv, because the version of ruby shipped with
# Ubuntu 12.04 has a bug we hit in Psych when loading YAML files.
export RBENV_VERSION="1.9.3"

bundle install --path "${HOME}/bundles/${JOB_NAME}" --shebang="/usr/bin/env ruby"

# Obtain the integration test parameters
git clone git@github.gds:gds/vcloud-tools-testing-config.git
mv vcloud-tools-testing-config/vcloud_tools_testing_config.yaml spec/integration/
rm -rf vcloud-tools-testing-config

bundle exec rake
RUBYOPT="-r ./tools/fog_credentials" bundle exec rake integration
