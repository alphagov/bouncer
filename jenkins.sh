#!/bin/bash -x

# Try to merge master into the current branch, and abort if it doesn't exit
# cleanly (ie there are conflicts). This will be a noop if the current branch
# is master.
git merge --no-commit origin/master || git merge --abort

bundle install --path "${HOME}/bundles/${JOB_NAME}"

dropdb transition_test
createdb --encoding=UTF8 --template=template0 transition_test
cat db/structure.sql | psql -d transition_test

RACK_ENV=test bundle exec rake --trace
