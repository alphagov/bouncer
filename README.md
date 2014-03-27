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

## Testing in a browser in development

These instructions assume you use the Dev VM, and that you have some data in
your Transition/Bouncer database.

Let's say you want to test `bis.gov.uk`.

Get the IP address of your VM:

    mac$ ping transition.dev.gov.uk

Then, add to hosts file on your Mac:

    mac$ cat /etc/hosts
    10.1.1.254 dev.bis.gov.uk

Then on your VM, as root, add this file:

    dev$ cat /etc/nginx/sites-enabled/bis.gov.uk
    server {
      server_name dev.bis.gov.uk;
      listen 80;

      location / {
        proxy_pass http://bouncer.dev.gov.uk-proxy;
        proxy_set_header Host bis.gov.uk;
      }
    }

Then link the file:

    dev$ sudo ln -s /etc/nginx/sites-available/bis.gov.uk /etc/nginx/sites-enabled/bis.gov.uk

And restart nginx:

    dev$ sudo service nginx restart

Now browse to http://dev.bis.gov.uk/410 and bask in the glory.
