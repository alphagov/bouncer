#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}"

./test_database_setup.sh

RACK_ENV=test bundle exec rake --trace
