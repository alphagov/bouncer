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

2. **Run the following command in the Transition repo.**

  ```
  bundle exec rake import:all:orgs_sites_hosts
  ```

  One of the created organisations will be "cabinet-office", which we will use in the next step.

3. **Create a temporary site file in the Transition repo.**

  ```
  site: bouncer-redirect
  whitehall_slug: cabinet-office
  homepage: https://www.gov.uk
  tna_timestamp: 20141104112824
  host: bouncer-redirect.dev.gov.uk
  global: =301 https://www.gov.uk
  ```

4. **Run the following command in the Transition repo.**

  ```
  bundle exec rake 'import:org_sites_hosts[<path-to-file>]'
  ```

  This will create the site in the shared Transition / Bouncer DB.

5. **Start the Bouncer app and go to bouncer-redirect.dev.gov.uk.**

  You should see that it redirects to GOV.UK, as specified in the site file.

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
