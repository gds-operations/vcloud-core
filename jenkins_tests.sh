#!/bin/bash
set -eu

function cleanup {
  set +e
  bundle exec vcloud-logout
  rm $FOG_RC
  unset FOG_RC
}

export FOG_RC=$(mktemp /tmp/vcloud_fog_rc.XXXXXXXXXX)
trap cleanup EXIT

cat <<EOF >${FOG_RC}
${FOG_CREDENTIAL}:
  vcloud_director_host: '${API_HOST}'
  vcloud_director_username: '${API_USERNAME}'
  vcloud_director_password: ''
EOF

git clean -ffdx

# We wish to force using a version of ruby installed with rbenv, because the version of ruby shipped with
# Ubuntu 12.04 has a bug we hit in Psych when loading YAML files.
export RBENV_VERSION="1.9.3"

bundle install --path "${HOME}/bundles/${JOB_NAME}" --shebang="/usr/bin/env ruby"

# Obtain the integration test parameters
git clone git@github.gds:gds/vcloud-tools-testing-config.git
mv vcloud-tools-testing-config/vcloud_tools_testing_config.yaml spec/integration/
rm -rf vcloud-tools-testing-config

# Never log token to STDOUT.
set +x
eval $(printenv API_PASSWORD | bundle exec vcloud-login)

bundle exec rake
bundle exec rake integration
