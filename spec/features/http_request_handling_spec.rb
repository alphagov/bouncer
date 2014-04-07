require 'spec_helper'

describe 'HTTP request handling' do
  include Rack::Test::Methods

  before :all do
    @app = Rack::Builder.parse_file('config.ru')[0]
  end

  let(:app) { @app }

  subject { last_response }

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
      abbr: 'minit',
      tna_timestamp: '2012-10-26 06:52:14',
      homepage: 'http://www.gov.uk/government/organisations/ministry-of-truth'
    ).tap do |site|
      site.hosts.create hostname: 'www.minitrue.gov.uk'
    end
  end

  shared_examples 'a server error' do
    its(:status)    { should == 500 }
    its(:location)  { should == nil }
    specify         { last_response.headers.should_not include('Cache-Control') }
  end

  shared_examples 'a 200' do
    its(:status)   { should == 200}
    specify        { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  shared_examples 'a redirect' do
    its(:status)   { should == 301 }
    specify        { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  shared_examples 'a 410' do
    its(:status) { should == 410 }
    its(:content_type) { should == 'text/html' }
    specify { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  shared_examples 'a 404' do
    its(:status) { should == 404 }
    specify { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  describe 'redirects get a cache header of 1 hour' do
    before do
      get 'http://www.minitrue.gov.uk'
    end

    it_behaves_like 'a redirect'
  end

  describe 'visiting a URL which has been redirected (but not canonicalised)' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
        http_status:  '301',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

      get 'http://www.minitrue.gov.uk/a-redirected-page///'
    end

    it_behaves_like 'a redirect'
    its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page' }
  end

  describe 'visiting a URL with query parameters which has been redirected' do
    before do
      site.update_attribute(:query_params, "a:b")
      site.mappings.create \
        path:         '/a-redirected-page?a=1&b=2',
        path_hash:    Digest::SHA1.hexdigest('/a-redirected-page?a=1&b=2'),
        http_status:  '301',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

      get 'https://www.MINITRUE.gov.uk/a-redirected-page?b=2&a=1'
    end

    it_behaves_like 'a redirect'
    its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page' }
  end

  describe 'visiting a redirected aka URL' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
        http_status:  '301',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
    end

    context "aka-hostname style" do
      before do
        site.hosts.first.update_attribute(:hostname, "minitrue.gov.uk")
        get 'http://aka-minitrue.gov.uk/a-redirected-page'
      end
      it_behaves_like 'a redirect'
      its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page' }
    end

    context "aka.hostname style" do
      before do
        get 'http://aka.minitrue.gov.uk/a-redirected-page'
      end
      it_behaves_like 'a redirect'
      its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page' }
    end
  end

  describe 'visiting a URL with significant query parameters' do
    before do
      site.update_attribute(:query_params, "itemid:style")
    end

    context 'site has significant query parameters' do
      before do
        site.mappings.create \
          path:         '/page?itemid=2&style=1',
          path_hash:    Digest::SHA1.hexdigest('/page?itemid=2&style=1'),
          http_status:  '301',
          new_url:      'http://www.gov.uk/foo'
      end

      it 'retains only the significant query parameters when finding the mapping' do
        # has the two important params and an irrelevant param
        get 'https://www.MINITRUE.gov.uk/page?itemid=2&irrelevant=x&style=1'
        last_response.location.should == 'http://www.gov.uk/foo'
      end

      it 'reorders the significant query parameters when finding the mapping' do
        # has the two params in wrong order
        get 'https://www.MINITRUE.gov.uk/page?style=1&itemid=2'
        last_response.location.should == 'http://www.gov.uk/foo'
      end
    end
  end

  context "visiting a URL where the site has blank string for query_params" do
    before do
      site.update_attribute(:query_params, "")
      site.mappings.create \
          path:         '/page',
          path_hash:    Digest::SHA1.hexdigest('/page'),
          http_status:  '301',
          new_url:      'http://www.gov.uk/foo'
    end

    it 'throw away all query params' do
      get 'https://www.MINITRUE.gov.uk/page?ignore=1&me=2'
      last_response.location.should == 'http://www.gov.uk/foo'
    end
  end

  describe 'visiting a URL which has been redirected to a site not on the whitelist' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
        http_status:  '301',
        new_url:      'http://spam.net/gov.uk'

      get 'https://www.minitrue.gov.uk/a-redirected-page'
    end

    its(:status) { should == 501 }
    its(:location) { should == nil }
  end

  describe 'visiting a URL which redirects to anything on *.gov.uk' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
        http_status:  '301',
        new_url:      'http://anything-at-all.gov.uk'

      get 'https://www.minitrue.gov.uk/a-redirected-page'
    end

    its(:status) { should == 301 }
    its(:location) { should == 'http://anything-at-all.gov.uk' }
  end

  describe 'visiting a URL which redirects to anything on *.mod.uk' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
        http_status:  '301',
        new_url:      'http://anything-at-all.mod.uk'

      get 'https://www.minitrue.gov.uk/a-redirected-page'
    end

    its(:status) { should == 301 }
    its(:location) { should == 'http://anything-at-all.mod.uk' }
  end

  describe 'visiting a URL which has been archived' do
    before do
      site.mappings.create \
        path:         '/an-archived-page',
        path_hash:    Digest::SHA1.hexdigest('/an-archived-page'),
        http_status:  '410'
      get 'http://www.minitrue.gov.uk/an-archived-page?non-canonical-param=1'
    end

    it_behaves_like 'a 410'

    its(:body) { should include '<title>410 - Page Archived</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-truth">' }
    its(:body) { should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/an-archived-page?non-canonical-param=1">This item has been archived</a>' }
  end

  describe 'visiting a URL which has been archived with a suggested URL' do
    before do
      site.mappings.create \
        path:           '/an-archived-page',
        path_hash:      Digest::SHA1.hexdigest('/an-archived-page'),
        http_status:    '410',
        suggested_url:  'http://www.truthiness.co.uk/'
      get 'http://www.minitrue.gov.uk/an-archived-page'
    end

    it_behaves_like 'a 410'

    its(:body) { should include '<title>410 - Page Archived</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-truth">' }
    its(:body) { should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/an-archived-page">This item has been archived</a>' }
    its(:body) { should include 'Visit <a href="http://www.truthiness.co.uk/">www.truthiness.co.uk</a> for more information on this topic.' }
  end

  describe 'visiting a URL which has been archived with an archive URL' do
    before do
      site.mappings.create \
        path:         '/an-archived-page',
        path_hash:    Digest::SHA1.hexdigest('/an-archived-page'),
        http_status:  '410',
        archive_url:  'http://webarchive.nationalarchives.gov.uk/20130101000000/http://www.minitrue.gov.uk/an-archived-page/the_actual_page.php'
      get 'http://www.minitrue.gov.uk/an-archived-page'
    end

    it_behaves_like 'a 410'

    its(:body) { should include '<title>410 - Page Archived</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-truth">' }
    its(:body) { should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20130101000000/http://www.minitrue.gov.uk/an-archived-page/the_actual_page.php">This item has been archived</a>' }
  end

  describe 'visiting an unrecognised path on a recognised host' do
    before do
      get 'http://www.minitrue.gov.uk/an-unrecognised-page'
    end

    it_behaves_like 'a 404'

    its(:content_type) { should == 'text/html' }

    its(:body) { should include '<title>404 - Not Found</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-truth">' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk">UK Government Web Archive</a>' }
  end

  describe 'visiting an unrecognised path on a different recognised host' do
    before do
      Organisation.create(homepage: 'http://www.gov.uk/government/organisations/ministry-of-love', title: 'Ministry of Love', css: 'ministry-of-love').
        sites.create(tna_timestamp: '2013-07-24 10:32:51', abbr: 'minil').
        hosts.create hostname: 'www.miniluv.gov.uk'

      get 'http://www.miniluv.gov.uk/an-unrecognised-page'
    end

    it_behaves_like 'a 404'

    its(:content_type) { should == 'text/html' }

    its(:body) { should include '<title>404 - Not Found</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-love"><span>Ministry of Love</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-love">' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20130724103251/http://www.miniluv.gov.uk">UK Government Web Archive</a>' }
  end

  describe 'sites with global_http_statuses' do
    describe 'sites with global redirects' do
      before do
        site.update_attribute(:global_http_status, '301')
        site.update_attribute(:global_new_url, 'http://www.gov.uk/global-new')
      end

      describe 'visiting the homepage' do
        before do
          get 'http://www.minitrue.gov.uk'
        end

        its(:location) { should == 'http://www.gov.uk/global-new' }
      end

      describe 'visiting a URL' do
        before do
          get 'http://www.minitrue.gov.uk/any-page'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://www.gov.uk/global-new' }
      end

      describe 'visiting a /404 URL' do
        before do
          get 'http://www.minitrue.gov.uk/404'
        end

        it_behaves_like 'a 404'
      end

      describe 'visiting a /410 URL' do
        before do
          get 'http://www.minitrue.gov.uk/410'
        end

        it_behaves_like 'a 410'
      end

      describe 'visiting /sitemap.xml' do
        before do
          site.mappings.create \
            path:         '/a-dummy-page',
            path_hash:    Digest::SHA1.hexdigest('/a-dummy-page'),
            http_status:  '301',
            new_url:      'http://www.gov.uk/new-page'
          get 'http://www.minitrue.gov.uk/sitemap.xml'
        end

        it_behaves_like 'a 200'

        its(:body) { should be_valid_xml }
        its(:body) { should be_valid_sitemap }
      end

      describe 'visiting /robots.txt' do
        before do
          get 'http://www.minitrue.gov.uk/robots.txt'
        end

        it_behaves_like 'a 200'

        its(:content_type) { should == 'text/plain' }
        its(:body) { should match %r{^User-agent: \*$} }
        its(:body) { should match %r{^Disallow:$} }
        its(:body) { should match %r{^Sitemap: http://www.minitrue.gov.uk/sitemap.xml$} }
      end
    end

    describe 'sites with global 410' do
      before do
        site.update_attribute(:global_http_status, '410')
      end

      describe 'visiting the homepage' do
        before do
          get 'http://www.minitrue.gov.uk'
        end

        it_behaves_like 'a 410'
      end

      describe 'visiting a URL' do
        before do
          get 'http://www.minitrue.gov.uk/any-page'
        end

        it_behaves_like 'a 410'
      end

      describe 'visiting a /404 URL' do
        before do
          get 'http://www.minitrue.gov.uk/404'
        end

        it_behaves_like 'a 404'
      end

      describe 'visiting a /410 URL' do
        before do
          get 'http://www.minitrue.gov.uk/410'
        end

        it_behaves_like 'a 410'
      end
    end

    describe 'sites with an unexpected global status' do
      before do
        site.update_attribute(:global_http_status, '999')
        get 'http://www.minitrue.gov.uk'
      end

      it_behaves_like 'a server error'
    end
  end

  describe 'visiting a /404 URL' do
    before do
      get 'http://www.minitrue.gov.uk/404'
    end

    it_behaves_like 'a 404'

    its(:content_type) { should == 'text/html' }

    its(:body) { should include '<title>404 - Not Found</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-truth">' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk">UK Government Web Archive</a>' }
  end

  describe 'escaping Database content in the 404 page' do
    before do
      organisation.update_attribute(:title, '<script>alert("xss");</script>Ministry of Truth')
      get 'http://www.minitrue.gov.uk/404'
    end

    its(:body) { should include '&lt;script&gt;alert(&quot;xss&quot;);&lt;/script&gt;Ministry of Truth'}
  end

  describe 'visiting a /410 URL' do
    before do
      get 'http://www.minitrue.gov.uk/410'
    end

    it_behaves_like 'a 410'

    its(:body) { should include '<title>410 - Page Archived</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-truth"><span>Ministry of Truth</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-truth">' }
    its(:body) { should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/410">This item has been archived</a>' }
  end

  describe 'visiting a /410 URL with no furl' do
    before do
      organisation.update_attribute(:furl, nil)
      get 'http://www.minitrue.gov.uk/410'
    end

    its(:body) { should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">http://www.gov.uk/government/organisations/ministry-of-truth</a>' }
  end

  describe 'visiting a /sitemap.xml URL' do
    before do
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
        path:         '/a-deleted-page',
        path_hash:    Digest::SHA1.hexdigest('/a-deleted-page'),
        http_status:  '404'
      site.mappings.create \
        path:         '/an-archived-page',
        path_hash:    Digest::SHA1.hexdigest('/an-archived-page'),
        http_status:  '410'

      get 'http://www.minitrue.gov.uk/sitemap.xml'
    end

    it_behaves_like 'a 200'

    its(:body) { should be_valid_xml }
    its(:body) { should be_valid_sitemap }
    its(:body) { should have_sitemap_entry_for 'http://www.minitrue.gov.uk/a-redirected-page' }
    its(:body) { should have_sitemap_entry_for 'http://www.minitrue.gov.uk/a-redirected-page?p=np' }
    its(:body) { should_not have_sitemap_entry_for 'http://www.minitrue.gov.uk/a-deleted-page' }
    its(:body) { should_not have_sitemap_entry_for 'http://www.minitrue.gov.uk/an-archived-page' }
    its(:content_type) { should == 'application/xml' }
  end

  describe 'visiting a /robots.txt URL' do
    before do
      get 'http://www.minitrue.gov.uk/robots.txt'
    end

    it_behaves_like 'a 200'

    its(:content_type) { should == 'text/plain' }
    its(:body) { should match %r{^User-agent: \*$} }
    its(:body) { should match %r{^Disallow:$} }
    its(:body) { should match %r{^Sitemap: http://www.minitrue.gov.uk/sitemap.xml$} }
  end

  describe 'visiting a homepage' do
    before do
      get 'http://www.minitrue.gov.uk'
    end

    it_behaves_like 'a redirect'

    its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth' }
  end

  describe 'visiting a homepage with a redirect to a site not on the whitelist' do
    before do
      site.update_attribute(:homepage, "http://spam.net/gov.uk")
      get 'http://www.minitrue.gov.uk'
    end

    its(:status) { should == 501 }
    its(:body) { should match %r{non\-whitelisted}}
    its(:body) { should match %r{spam.net} }
    its(:location) { should == nil }
  end

  context 'when the host is not recognised' do
    describe 'visiting the homepage' do
      before do
        get 'http://www.minipax.gov.uk/'
      end

      it_behaves_like 'a 404'
      its(:body) { should be_empty }
    end

    describe 'visiting another page' do
      before do
        get 'http://www.minipax.gov.uk/an-unrecognised-page'
      end

      it_behaves_like 'a 404'
      its(:body) { should be_empty }
    end

    describe 'visiting /healthcheck' do
      before do
        get 'http://www.minipax.gov.uk/healthcheck'
      end

      it_behaves_like 'a 200'
      its(:body) { should match %r{^OK$} }
    end
  end

  describe 'cases which break things in a vexing manner' do
    # In dev (but not production), CommonLogger middleware is in use, which expects
    # us not to violate the Rack spec. Part of this is not allowing nil query strings,
    # which at time of writing optic14n does.
    let(:app) { Rack::CommonLogger.new(Rack::Builder.parse_file('config.ru')[0]) }

    describe 'Nil querystrings do not faze us' do
      before do
        path = '/an-archived-page'
        site.mappings.create \
          path: path,
          path_hash:    Digest::SHA1.hexdigest(path),
          http_status:  '410'

        get "http://www.minitrue.gov.uk#{path}"
      end

      it_behaves_like 'a 410'
    end

    describe 'parameters without values do not get thrown away' do
      before do
        path = '/an-archived-page?with&a&weird&querystring'
        site.update_attribute(:query_params, "with:a:weird:querystring")
        site.mappings.create \
          path: path,
          path_hash:    Digest::SHA1.hexdigest('/an-archived-page?a&querystring&weird&with'),
          http_status:  '410'

        get "http://www.minitrue.gov.uk#{path}"
      end

      it_behaves_like 'a 410'
    end
  end

  describe 'rules' do
    describe 'DFID redirects' do
      describe 'visiting a R4D URL' do
        before do
          site.hosts.create hostname: 'www.dfid.gov.uk'

          get 'http://www.dfid.gov.uk/r4d/Output/193679/Default.aspx'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://r4d.dfid.gov.uk/Output/193679/Default.aspx' }
      end
    end

    describe 'DH redirects' do
      let!(:dh_site) {
        department_of_health.sites.create(
            abbr: 'dh',
            tna_timestamp: '2012-10-26 06:52:14',
            homepage: 'https://www.gov.uk/government/organisations/department-of-health'
        ).tap do |site|
          site.hosts.create hostname: 'www.dh.gov.uk'
        end
      }

      describe 'visiting a /dh_digitalassets/ URL' do
        before do
          get 'http://www.dh.gov.uk/a/b/dh_digitalassets/c'
        end

        it_behaves_like 'a 410'

        its(:content_type) { should == 'text/html' }
        its(:body) { should include '<title>410 - Page Archived</title>' }
        its(:body) { should include '<a href="https://www.gov.uk/government/organisations/department-of-health"><span>Department of Health</span></a>' }
        its(:body) { should include '<div class="organisation department-of-health">' }
        its(:body) { should include 'Visit the new Department of Health site at <a href="https://www.gov.uk/government/organisations/department-of-health">www.gov.uk/doh</a>' }
        its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.dh.gov.uk/a/b/dh_digitalassets/c">This item has been archived</a>' }
      end

      context 'When a mapping exists that would trump the regex' do
        before do
          path = '/dh_digitalassets/really-special-asset'

          dh_site.mappings.create \
              path:        path,
              path_hash:   Digest::SHA1.hexdigest(path),
              http_status: '301',
              new_url:     'http://www.gov.uk/government/organisations/dh/really-special-asset'

          get 'http://www.dh.gov.uk/dh_digitalassets/really-special-asset'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://www.gov.uk/government/organisations/dh/really-special-asset' }
      end
    end

    describe 'Directgov redirects' do
      before { site.hosts.create hostname: 'www.direct.gov.uk' }

      describe 'visiting a /en search URL' do
        before do
          get 'http://www.direct.gov.uk/a/b/en/AdvancedSearch'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'https://www.gov.uk/search' }
      end

      describe 'visiting a non-/en search URL' do
        before do
          get 'http://www.direct.gov.uk/a/b/AdvancedSearch'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'https://www.gov.uk/search' }
      end

      describe 'visiting a Fire Kills URL' do
        before do
          site.hosts.create hostname: 'campaigns.direct.gov.uk'

          get 'http://campaigns.direct.gov.uk/a/firekills/b'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'https://www.gov.uk/firekills' }
      end
    end

    describe 'Environment Agency' do
      before { site.hosts.create hostname: 'www.environment-agency.gov.uk' }

      describe 'Flood Warnings redirects' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/34678.aspx?type=Region&term=Anglian'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/flood/34678.aspx?type=Region&term=Anglian' }
      end

      describe 'Flood Warnings redirects (Welsh)' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/cy/34678.aspx?type=Region&term=Wales&Severity=1'
        end

        it_behaves_like 'a redirect'
        its(:location) { should  == 'http://apps.environment-agency.gov.uk/flood/cy/34678.aspx?type=Region&term=Wales&Severity=1' }
      end

      describe 'River Levels redirects' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels/120691.aspx?foo=bar'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels/120691.aspx?foo=bar'}
      end

      describe 'River Levels redirects (Welsh)' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels/cy/120691.aspx?foo=bar'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels/cy/120691.aspx?foo=bar' }
      end

      describe 'river levels homepage' do
        describe 'with trailing slash' do
          before do
            get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels/'
          end

          it_behaves_like 'a redirect'
          its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels/' }
        end

        describe 'without trailing slash' do
          before do
            get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels'
          end

          it_behaves_like 'a redirect'
          its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels' }
        end
      end

      describe 'overrides any mapping (PreemptiveRules)' do
        before do
          path = '/homeandleisure/floods/34678.aspx?page=1'
          site.mappings.create(path: path, path_hash: Digest::SHA1.hexdigest(path), http_status: 410)
          get "http://www.environment-agency.gov.uk#{path}"
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/flood/34678.aspx?page=1'}
      end

      describe 'URL that shouldn\'t match' do
        before do
          get('http://www.environment-agency.gov.uk/homeandleisure/floods/31632.aspx')
        end

        it_behaves_like 'a 404'
        its(:location) { should == nil }
      end
    end

    describe 'Number 10 redirects' do
      before { site.hosts.create hostname: 'www.number10.gov.uk' }

      describe 'visiting a news URL' do
        before do
          get 'http://www.number10.gov.uk/news/latest-news/2007/06/Brown-unveils-new-faces-12225'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://www.number10.gov.uk/news/brown-unveils-new-faces' }
      end
    end

    describe 'Treasury redirects' do
      before { site.hosts.create hostname: 'cdn.hm-treasury.gov.uk' }

      describe 'visiting a CDN /* URL' do
        before do
          get 'http://cdn.hm-treasury.gov.uk/budget2013_complete.pdf'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'http://www.hm-treasury.gov.uk/budget2013_complete.pdf' }
      end
    end

    describe 'GDS blog redirects' do
      before { site.hosts.create hostname: 'digital.cabinetoffice.gov.uk' }

      describe 'visiting a /* URL' do
        before do
          get 'http://digital.cabinetoffice.gov.uk/tag/david-mann'
        end

        it_behaves_like 'a redirect'
        its(:location) { should == 'https://gds.blog.gov.uk/tag/david-mann' }
      end
    end
  end
end
