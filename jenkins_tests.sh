#!/bin/bash -x
set -e

git clean -ffdx

# We wish to force using a version of ruby installed with rbenv, because the version of ruby shipped with
# Ubuntu 12.04 has a bug we hit in Psych when loading YAML files.
RBENV_VERSION="1.9.3"

#FIXME: This can be removed once the tests have cycled through all 4 CI machines (a week or two after #100 is merged)
# As we weren't using rbenv before, we've ended up with binstubs referencing ruby1.9.1
# This line detects them, deletes the cache if it finds any and forces a new build with --shebang ruby
grep -Rq ruby1\.9\.1 ${HOME}/bundles/${JOB_NAME}/ruby/1.9.1/bin && echo "Deleting cached gems with ruby1.9.1 shebangs" && rm -rf ${HOME}/bundles/${JOB_NAME}/*
# END FIXME
bundle install --path "${HOME}/bundles/${JOB_NAME}" --shebang ruby

# Obtain the integration test parameters
git clone git@github.gds:gds/vcloud-tools-testing-config.git
mv vcloud-tools-testing-config/vcloud_tools_testing_config.yaml spec/integration/
rm -rf vcloud-tools-testing-config

bundle exec rake
RUBYOPT="-r ./tools/fog_credentials" bundle exec rake integration
