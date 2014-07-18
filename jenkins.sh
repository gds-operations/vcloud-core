#!/bin/bash -x
set -e

./jenkins_test.sh
bundle exec rake publish_gem
