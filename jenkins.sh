#!/bin/bash -x
set -e

rm -f Gemfile.lock
git clean -fdx

bundle install --path "${HOME}/bundles/${JOB_NAME}"

# Obtain the integration test parameters
git clone git@github.gds:gds/vcloud-tools-testing-config.git
mv vcloud-tools-testing-config/vcloud_tools_testing_config.yaml spec/integration/

bundle exec rake
RUBYOPT="-r ./tools/fog_credentials" bundle exec rake integration
bundle exec rake publish_gem
