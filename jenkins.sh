#!/bin/bash -x
bundle install --path "${HOME}/bundles/${JOB_NAME}"

mysql -u transition -ptransition -e 'DROP DATABASE transition_test'
mysql -u transition -ptransition -e 'CREATE DATABASE transition_test'
mysql -u transition -ptransition -D transition_test < db/structure.sql

RACK_ENV=test bundle exec rake --trace
