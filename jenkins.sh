#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}"

dropdb transition_test
createdb --encoding=UTF8 --template=template0 transition_test
sudo -u postgres psql -d transition_test -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto'
cat db/structure.sql | psql -d transition_test

RACK_ENV=test bundle exec rake --trace
