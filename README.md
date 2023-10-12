# bouncer

This is a Rack-based redirector. It serves 301s and 410s from mappings created by [Transition](https://github.com/alphagov/transition).

## Technical documentation

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the tests

```
bundle exec rake
```

### Testing redirects

In order to test the redirect feature of this app, you can use a special `bouncer-redirect.dev.gov.uk` domain. We will create a mapping from this fake domain to GOV.UK.

1. **Setup [the Transition repo](https://github.com/alphagov/transition).**

  One of the seeded organisations will be "Cabinet Office", which we will use in the next step.

2. **In the Transition app, [under the Cabinet Office organisation](http://transition.dev.gov.uk/organisations/cabinet-office), add a new site.**

  | | |
  | --- | --- |
  | **Abbreviated name:** | bouncer-redirect |
  | **TNA timestamp:** | 20141104112824 |
  | **Homepage:** | https://www.gov.uk |
  | **Hostname:** | bouncer-redirect.dev.gov.uk |
  | **Global type:** | Redirect |
  | **... with Global new URL:** | https://www.gov.uk |

  This will create the site in the shared Transition / Bouncer DB.

3. **Start the Bouncer app and go to bouncer-redirect.dev.gov.uk.**

  You should see that it redirects to GOV.UK, as specified in the site file.

### Testing on staging environment

In contrast to other GOV.UK applications, Bouncer isn't available at x.staging.publishing.service.gov.uk

This means that testing the application on our staging environment will require repointing the domains you wish to test by editing your computer’s host file to point them at Bouncer’s staging IP address. This should allow visiting the app in a web browser, for example. Alternatively, to make a request to our staging environment with curl:

```
curl -I -H"Host: www.attorneygeneral.gov.uk" http://0.0.0.0/aboutus/pages/civilcriminalpanels.aspx
```

### Data storage

Lists of domain names, old URLs and URLs to redirect to are stored in a
PostgreSQL database to which the application has read-only access.

## Example application URLs

Here are some examples using a few of the many domain names which is served by
Bouncer:

| URL | Description |
| --- | ----------- |
| http://www.attorneygeneral.gov.uk/aboutus/pages/civilcriminalpanels.aspx | Serves a redirect to a page on GOV.UK |
| http://www.bonavacantia.gov.uk/output/accessibility.aspx | Serves a 410 archive page |
| http://rdpenetwork.defra.gov.uk/i-made-this-up | Serves a 404 not found page |
| http://www.attorneygeneral.gov.uk/sitemap.xml | Serves a sitemap of all redirects for the domain |
| http://www.attorneygeneral.gov.uk/robots.txt | Serves a minimal robots.txt |


## Licence

[MIT License](LICENCE)
