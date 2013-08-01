#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}"

RACK_ENV=test bundle exec rake --trace
