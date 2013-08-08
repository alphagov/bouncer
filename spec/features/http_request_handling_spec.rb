require 'spec_helper'

describe 'HTTP request handling' do
  include Rack::Test::Methods

  let(:app) { Rack::Builder.parse_file('config.ru')[0] }

  let(:department_of_health) do
    Organisation.create \
      homepage: 'https://www.gov.uk/government/organisations/department-of-health',
      title: 'Department of Health',
      css: 'department-of-health',
      furl: 'www.gov.uk/doh'
  end

  let(:organisation) do
    Organisation.create \
      homepage: 'http://www.gov.uk/government/organisations/ministry-of-truth',
      title: 'Ministry of Truth',
      css: 'ministry-of-truth',
      furl: 'www.gov.uk/mot'
  end

  let!(:site) do
    organisation.sites.create(
      tna_timestamp: '2012-10-26 06:52:14',
      homepage: 'http://www.gov.uk/government/organisations/ministry-of-truth'
    ).tap do |site|
      site.hosts.create host: 'www.minitrue.gov.uk'
    end
  end

  specify 'visiting a URL which has been redirected (but not canonicalised)' do
    site.mappings.create \
      path:         '/a-redirected-page',
      path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
      http_status:  '301',
      new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

    get 'http://www.minitrue.gov.uk/a-redirected-page///'
    last_response.should be_redirect
    last_response.status.should == 301
    last_response.location.should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
  end

  specify 'visiting a URL with query parameters which has been redirected' do
    site.mappings.create \
      path:         '/a-redirected-page?a=1&b=2',
      path_hash:    Digest::SHA1.hexdigest('/a-redirected-page?a=1&b=2'),
      http_status:  '301',
      new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

    get 'https://www.MINITRUE.gov.uk/a-redirected-page?b=2&a=1'
    last_response.should be_redirect
    last_response.status.should == 301
    last_response.location.should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
  end

  specify 'visiting a URL which has been archived' do
    site.mappings.create \
      path:         '/an-archived-page',
      path_hash:    Digest::SHA1.hexdigest('/an-archived-page'),
      http_status:  '410'

    get 'http://www.minitrue.gov.uk/an-archived-page'
    last_response.should be_client_error
    last_response.status.should == 410
    last_response.body.should include '<title>410 - Page Archived</title>'
    last_response.body.should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>'
    last_response.body.should include '<div class="organisation ministry-of-truth">'
    last_response.body.should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>'
    last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/an-archived-page">This item has been archived</a>'
    last_response.content_type.should == 'text/html'
  end

  specify 'visiting a URL which has been archived with a suggested URL' do
    site.mappings.create \
      path:           '/an-archived-page',
      path_hash:      Digest::SHA1.hexdigest('/an-archived-page'),
      http_status:    '410',
      suggested_url:  'http://www.truthiness.co.uk/'

    get 'http://www.minitrue.gov.uk/an-archived-page'
    last_response.should be_client_error
    last_response.status.should == 410
    last_response.body.should include '<title>410 - Page Archived</title>'
    last_response.body.should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>'
    last_response.body.should include '<div class="organisation ministry-of-truth">'
    last_response.body.should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>'
    last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/an-archived-page">This item has been archived</a>'
    last_response.body.should include 'Visit <a href="http://www.truthiness.co.uk/">www.truthiness.co.uk</a> for more information on this topic.'
    last_response.content_type.should == 'text/html'
  end

  specify 'visiting a URL which has been archived with an archive URL' do
    site.mappings.create \
      path:         '/an-archived-page',
      path_hash:    Digest::SHA1.hexdigest('/an-archived-page'),
      http_status:  '410',
      archive_url:  'http://webarchive.nationalarchives.gov.uk/20130101000000/http://www.minitrue.gov.uk/an-archived-page/the_actual_page.php'

    get 'http://www.minitrue.gov.uk/an-archived-page'
    last_response.should be_client_error
    last_response.status.should == 410
    last_response.body.should include '<title>410 - Page Archived</title>'
    last_response.body.should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>'
    last_response.body.should include '<div class="organisation ministry-of-truth">'
    last_response.body.should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>'
    last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20130101000000/http://www.minitrue.gov.uk/an-archived-page/the_actual_page.php">This item has been archived</a>'
    last_response.content_type.should == 'text/html'
  end

  specify 'visiting an unrecognised path on a recognised host' do
    get 'http://www.minitrue.gov.uk/an-unrecognised-page'
    last_response.should be_not_found
    last_response.body.should include '<title>404 - Not Found</title>'
    last_response.body.should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>'
    last_response.body.should include '<div class="organisation ministry-of-truth">'
    last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk">UK Government Web Archive</a>'
    last_response.content_type.should == 'text/html'
  end

  specify 'visiting an unrecognised path on a different recognised host' do
    Organisation.create(homepage: 'http://www.gov.uk/government/organisations/ministry-of-love', title: 'Ministry of Love', css: 'ministry-of-love').
      sites.create(tna_timestamp: '2013-07-24 10:32:51').
      hosts.create host: 'www.miniluv.gov.uk'

    get 'http://www.miniluv.gov.uk/an-unrecognised-page'
    last_response.should be_not_found
    last_response.body.should include '<title>404 - Not Found</title>'
    last_response.body.should include '<a href="http://www.gov.uk/government/organisations/ministry-of-love"><span>Ministry of Love</span></a>'
    last_response.body.should include '<div class="organisation ministry-of-love">'
    last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20130724103251/http://www.miniluv.gov.uk">UK Government Web Archive</a>'
    last_response.content_type.should == 'text/html'
  end

  specify 'visiting a /404 URL' do
    get 'http://www.minitrue.gov.uk/404'
    last_response.should be_not_found
    last_response.body.should include '<title>404 - Not Found</title>'
    last_response.body.should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>'
    last_response.body.should include '<div class="organisation ministry-of-truth">'
    last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk">UK Government Web Archive</a>'
    last_response.content_type.should == 'text/html'
  end

  specify 'visiting a /410 URL' do
    get 'http://www.minitrue.gov.uk/410'
    last_response.should be_client_error
    last_response.status.should == 410
    last_response.body.should include '<title>410 - Page Archived</title>'
    last_response.body.should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>'
    last_response.body.should include '<div class="organisation ministry-of-truth">'
    last_response.body.should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>'
    last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/410">This item has been archived</a>'
    last_response.content_type.should == 'text/html'
  end

  specify 'visiting a /sitemap.xml URL' do
    site.mappings.create \
      path:         '/a-redirected-page',
      path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
      http_status:  '301',
      new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
    site.mappings.create \
      path:         '/a-redirected-page?p=np',
      path_hash:    Digest::SHA1.hexdigest('/a-redirected-page?p=np'),
      http_status:  '301',
      new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
    site.mappings.create \
      path:         '/an-archived-page',
      path_hash:    Digest::SHA1.hexdigest('/an-archived-page'),
      http_status:  '410'

    get 'http://www.minitrue.gov.uk/sitemap.xml'
    last_response.should be_ok
    last_response.body.should be_valid_xml
    last_response.body.should be_valid_sitemap
    last_response.body.should have_sitemap_entry_for 'http://www.minitrue.gov.uk/a-redirected-page'
    last_response.body.should have_sitemap_entry_for 'http://www.minitrue.gov.uk/a-redirected-page?p=np'
    last_response.body.should have_sitemap_entry_for 'http://www.minitrue.gov.uk/an-archived-page'
    last_response.content_type.should == 'application/xml'
  end

  specify 'visiting a /robots.txt URL' do
    get 'http://www.minitrue.gov.uk/robots.txt'
    last_response.should be_ok
    last_response.body.should match %r{^User-agent: \*$}
    last_response.body.should match %r{^Disallow:$}
    last_response.body.should match %r{^Sitemap: http://www.minitrue.gov.uk/sitemap.xml$}
    last_response.content_type.should == 'text/plain'
  end

  specify 'visiting a homepage' do
    get 'http://www.minitrue.gov.uk'
    last_response.should be_redirect
    last_response.status.should == 301
    last_response.location.should == 'http://www.gov.uk/government/organisations/ministry-of-truth'
  end

  context 'when the host is not recognised' do
    specify 'visiting the homepage' do
      get 'http://www.minipax.gov.uk/'
      last_response.should be_not_found
      last_response.body.should be_empty
    end

    specify 'visiting another page' do
      get 'http://www.minipax.gov.uk/an-unrecognised-page'
      last_response.should be_not_found
      last_response.body.should be_empty
    end

    specify 'visiting /healthcheck' do
      get 'http://www.minipax.gov.uk/healthcheck'
      last_response.should be_ok
      last_response.body.should match %r{^OK$}
    end
  end

  describe 'cases which break things in a vexing manner' do
    # In dev (but not production), CommonLogger middleware is in use, which expects
    # us not to violate the Rack spec. Part of this is not allowing nil query strings,
    # which at time of writing optic14n does.
    let(:app) { Rack::CommonLogger.new(Rack::Builder.parse_file('config.ru')[0]) }

    specify 'Nil querystrings do not faze us' do
      path = '/an-archived-page'
      site.mappings.create \
        path: path,
        path_hash:    Digest::SHA1.hexdigest(path),
        http_status:  '410'

      get "http://www.minitrue.gov.uk#{path}"

      last_response.status.should == 410
    end

    specify 'Non HTML-encoded querystrings do not get thrown away' do
      path = '/an-archived-page?with&a&weird&querystring'
      site.mappings.create \
        path: path,
        path_hash:    Digest::SHA1.hexdigest('/an-archived-page?a&querystring&weird&with'),
        http_status:  '410'

      get "http://www.minitrue.gov.uk#{path}"

      last_response.status.should == 410
    end
  end

  describe 'rule-based redirects' do
    describe 'DFID redirects' do
      specify 'visiting a R4D URL' do
        site.hosts.create host: 'www.dfid.gov.uk'

        get 'http://www.dfid.gov.uk/r4d/Output/193679/Default.aspx'

        last_response.should be_redirect
        last_response.location.should == 'http://r4d.dfid.gov.uk/output/193679/default.aspx'
      end
    end

    describe 'DH redirects' do
      let!(:dh_site) {
        department_of_health.sites.create(
            tna_timestamp: '2012-10-26 06:52:14',
            homepage: 'https://www.gov.uk/government/organisations/department-of-health'
        ).tap do |site|
          site.hosts.create host: 'www.dh.gov.uk'
        end
      }

      specify 'visiting a /dh_digitalassets/ URL' do
        get 'http://www.dh.gov.uk/a/b/dh_digitalassets/c'

        last_response.should be_client_error
        last_response.status.should == 410
        last_response.body.should include '<title>410 - Page Archived</title>'
        last_response.body.should include '<a href="https://www.gov.uk/government/organisations/department-of-health"><span>Department of Health</span></a>'
        last_response.body.should include '<div class="organisation department-of-health">'
        last_response.body.should include 'Visit the new Department of Health site at <a href="https://www.gov.uk/government/organisations/department-of-health">www.gov.uk/doh</a>'
        last_response.body.should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.dh.gov.uk/a/b/dh_digitalassets/c">This item has been archived</a>'
        last_response.content_type.should == 'text/html'
      end

      context 'When a mapping exists that would trump the regex' do
        it 'lets the mapping go first' do
          path = '/dh_digitalassets/really-special-asset'

          dh_site.mappings.create \
            path:         path,
            path_hash:    Digest::SHA1.hexdigest(path),
            http_status:  '301',
            new_url:      'http://www.gov.uk/government/organisations/dh/really-special-asset'

          get 'http://www.dh.gov.uk/dh_digitalassets/really-special-asset'

          last_response.should be_redirect
          last_response.location.should == 'http://www.gov.uk/government/organisations/dh/really-special-asset'
        end
      end
    end

    describe 'Directgov redirects' do
      before { site.hosts.create host: 'www.direct.gov.uk' }

      specify 'visiting a /en search URL' do
        get 'http://www.direct.gov.uk/a/b/en/AdvancedSearch'

        last_response.should be_redirect
        last_response.location.should == 'https://www.gov.uk/search'
      end

      specify 'visiting a non-/en search URL' do
        get 'http://www.direct.gov.uk/a/b/AdvancedSearch'

        last_response.should be_redirect
        last_response.location.should == 'https://www.gov.uk/search'
      end

      specify 'visiting a Fire Kills URL' do
        site.hosts.create host: 'campaigns.direct.gov.uk'

        get 'http://campaigns.direct.gov.uk/a/firekills/b'

        last_response.should be_redirect
        last_response.location.should == 'https://www.gov.uk/firekills'
      end
    end

    describe 'Number 10 redirects' do
      before { site.hosts.create host: 'www.number10.gov.uk' }

      specify 'visiting a news URL' do
        get 'http://www.number10.gov.uk/news/latest-news/2007/06/Brown-unveils-new-faces-12225'

        last_response.should be_redirect
        last_response.location.should == 'http://www.number10.gov.uk/news/brown-unveils-new-faces'
      end
    end

    describe 'Treasury redirects' do
      before { site.hosts.create host: 'cdn.hm-treasury.gov.uk' }

      specify 'visiting a CDN /d/* URL' do
        get 'http://cdn.hm-treasury.gov.uk/d/dataset3.csv'

        last_response.should be_redirect
        last_response.location.should == 'http://www.hm-treasury.gov.uk/dataset3.csv'
      end
    end
  end
end
