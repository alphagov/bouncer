#!/bin/bash

bundle install
bundle exec rackup -o '0.0.0.0' -p 3049
