# bouncer

This is a Rack-based redirector. It serves 301s and 410s from mappings created by [Transition](https://github.com/alphagov/transition).

## Testing in a browser in development

These instructions assume you use the Dev VM, that Bouncer is running,
and that you have some data in your Transition/Bouncer database.

Let's say you want to test `bis.gov.uk`.

Get the IP address of your VM:

    mac$ ping transition.dev.gov.uk

Then, add to hosts file on your Mac:

    mac$ cat /etc/hosts
    10.1.1.254 dev.bis.gov.uk

Then on your VM, as root, add this file:

    dev$ cat /etc/nginx/sites-available/bis.gov.uk
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
