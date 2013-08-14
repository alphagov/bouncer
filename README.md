# bouncer

This is a Rack-based redirector. It's being written as part of the agency transition effort and should,
in time, replace [redirector](https://github.com/alphagov/redirector). But not just yet. In order for bouncer
to even be considered for replacing redirector, the smoke tests should pass (see below)

## Running the smoke tests

1. Clone https://github.com/alphagov/redirector.
1. If the 'bouncer' branch still exists/has not been merged yet, use that
1. Run bouncer locally (e.g. just `rackup` in the bouncer directory)
1. `export REDIRECTOR=localhost:9292` (or wherever bouncer is running)
1. `cd redirector`, run `tools/smoke_tests.sh`

That should send a lot of HTTP requests to wherever $REDIRECTOR is pointing at
AFAICT it only tells you about the failures, but that's enough to get started

