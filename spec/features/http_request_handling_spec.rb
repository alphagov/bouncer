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
      title: 'Department of Health',
      css: 'department-of-health'
  end

  let(:organisation) do
    Organisation.create \
      title: 'Ministry of Truth',
      css: 'ministry-of-truth'
  end

  let!(:site) do
    organisation.sites.create(
      abbr: 'minit',
      tna_timestamp: '2012-10-26 06:52:14',
      homepage: 'http://www.gov.uk/government/organisations/ministry-of-truth',
      homepage_furl: 'www.gov.uk/mot'
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
    its(:status)   { should == 200 }
    specify        { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  shared_examples 'a 301' do
    its(:status) { should == 301 }
    specify      { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  shared_examples 'a 410' do
    its(:status) { should == 410 }
    its(:content_type) { should == 'text/html' }
    specify      { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  shared_examples 'a 404' do
    its(:status) { should == 404 }
    specify { last_response.headers['Cache-Control'].should == 'public, max-age=3600' }
  end

  describe 'redirects get a cache header of 1 hour' do
    before do
      get 'http://www.minitrue.gov.uk'
    end

    it_behaves_like 'a 301'
  end

  describe 'visiting a URL which has been redirected (but not canonicalised)' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        type:         'redirect',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

      get 'http://www.minitrue.gov.uk/a-redirected-page///'
    end

    it_behaves_like 'a 301'
    its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page' }
  end

  describe 'visiting a URL with query parameters which has been redirected' do
    before do
      site.update_attribute(:query_params, "a:b")
      site.mappings.create \
        path:         '/a-redirected-page?a=1&b=2',
        type:         'redirect',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

      get 'https://www.MINITRUE.gov.uk/a-redirected-page?b=2&a=1'
    end

    it_behaves_like 'a 301'
    its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page' }
  end

  describe 'visiting a redirected aka URL' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        type:         'redirect',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
    end

    context "aka-hostname style" do
      before do
        site.hosts.first.update_attribute(:hostname, "minitrue.gov.uk")
        get 'http://aka-minitrue.gov.uk/a-redirected-page'
      end
      it_behaves_like 'a 301'
      its(:location) { should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page' }
    end

    context "aka.hostname style" do
      before do
        get 'http://aka.minitrue.gov.uk/a-redirected-page'
      end
      it_behaves_like 'a 301'
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
          type:         'redirect',
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
          type:         'redirect',
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
        type:         'redirect',
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
        type:         'redirect',
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
        type:         'redirect',
        new_url:      'http://anything-at-all.mod.uk'

      get 'https://www.minitrue.gov.uk/a-redirected-page'
    end

    its(:status) { should == 301 }
    its(:location) { should == 'http://anything-at-all.mod.uk' }
  end

  describe 'visiting a URL which redirects to a URL including square brackets' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        type:         'redirect',
        new_url:      'http://www.gov.uk/[0]'

      get 'http://www.minitrue.gov.uk/a-redirected-page'
    end

    it_behaves_like 'a 301'
    its(:location) { should == 'http://www.gov.uk/[0]' }
  end

  describe 'visiting a URL which has been archived' do
    before do
      site.mappings.create \
        path:         '/an-archived-page',
        type:         'archive'
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
        type:           'archive',
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

  describe 'visiting a URL about which no decision has been made' do
    before do
      site.mappings.create \
        path:           '/an-unresolved-page',
        type:           'unresolved'
      get 'http://www.minitrue.gov.uk/an-unresolved-page'
    end

    it_behaves_like 'a 410'
  end

  describe 'visiting a URL which has been archived with an archive URL' do
    before do
      site.mappings.create \
        path:         '/an-archived-page',
        type:         'archive',
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

  describe 'visiting a URL which has been archived on a site with a custom title' do
    before do
      site.update_attribute(:homepage_title, 'Custom Title')
      site.mappings.create \
        path:         '/an-archived-page',
        type:         'archive'
      get 'http://www.minitrue.gov.uk/an-archived-page'
    end

    it_behaves_like 'a 410'

    its(:body) { should include 'Visit the new Custom Title site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">www.gov.uk/mot</a>' }
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
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/an-unrecognised-page">UK Government Web Archive</a>' }
  end

  describe 'visiting an unrecognised path on a different recognised host' do
    before do
      Organisation.create(css: 'ministry-of-love', title: 'Ministry of Love').
        sites.create(tna_timestamp: '2013-07-24 10:32:51', abbr: 'minil', homepage: 'http://www.gov.uk/government/organisations/ministry-of-love').
        hosts.create hostname: 'www.miniluv.gov.uk'

      get 'http://www.miniluv.gov.uk/an-unrecognised-page'
    end

    it_behaves_like 'a 404'

    its(:content_type) { should == 'text/html' }

    its(:body) { should include '<title>404 - Not Found</title>' }
    its(:body) { should include '<a href="http://www.gov.uk/government/organisations/ministry-of-love"><span>Ministry of Love</span></a>' }
    its(:body) { should include '<div class="organisation ministry-of-love">' }
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20130724103251/http://www.miniluv.gov.uk/an-unrecognised-page">UK Government Web Archive</a>' }
  end

  describe 'sites with global types' do
    describe 'sites with global redirects' do
      before do
        site.update_attribute(:global_type, 'redirect')
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

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.gov.uk/global-new' }
      end

      describe 'sites where we append the original path' do
        before do
          site.update_attribute(:global_redirect_append_path, true)
          get 'http://www.minitrue.gov.uk/my-page'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.gov.uk/global-new/my-page' }
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
            type:         'redirect',
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

    describe 'sites with global archive' do
      before do
        site.update_attribute(:global_type, 'archive')
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

    describe 'sites with an unexpected global type' do
      before do
        site.update_attribute(:global_type, 'nonsense')
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
    its(:body) { should include '<a href="http://webarchive.nationalarchives.gov.uk/20121026065214/http://www.minitrue.gov.uk/404">UK Government Web Archive</a>' }
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
      site.update_attribute(:homepage_furl, nil)
      get 'http://www.minitrue.gov.uk/410'
    end

    its(:body) { should include 'Visit the new Ministry of Truth site at <a href="http://www.gov.uk/government/organisations/ministry-of-truth">http://www.gov.uk/government/organisations/ministry-of-truth</a>' }
  end

  describe 'visiting a /sitemap.xml URL' do
    before do
      site.mappings.create \
        path:         '/a-redirected-page',
        type:         'redirect',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
      site.mappings.create \
        path:         '/a-redirected-page?p=np',
        type:         'redirect',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
      site.mappings.create \
        path:         '/a-deleted-page',
        type:         'never served'
      site.mappings.create \
        path:         '/an-archived-page',
        type:         'archive'

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

  describe 'visiting a /sitemap.xml URL for a site with a large number of redirects' do
    let(:maximum_size) { 10 }

    before do
      stub_const('Bouncer::Outcome::Sitemap::MAXIMUM_SIZE', maximum_size)
      (1..maximum_size + 1).each do |index|
        site.mappings.create \
        path:         "/a-redirected-page-#{index}",
        type:         'redirect',
        new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
      end

      get 'http://www.minitrue.gov.uk/sitemap.xml'
    end

    it 'should include the first n entries' do
      last_response.status.should be(200)
      last_response.body.should have_so_many_sitemap_entries(maximum_size)
      last_response.body.should have_sitemap_entry_for("http://www.minitrue.gov.uk/a-redirected-page-#{maximum_size}")
      last_response.body.should_not have_sitemap_entry_for("http://www.minitrue.gov.uk/a-redirected-page-#{maximum_size + 1}")
    end
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

    it_behaves_like 'a 301'

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
      its(:body) { should eql('This host is not configured in Transition') }
    end

    describe 'visiting another page' do
      before do
        get 'http://www.minipax.gov.uk/an-unrecognised-page'
      end

      it_behaves_like 'a 404'
      its(:body) { should eql('This host is not configured in Transition') }
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
          type:         'archive'

        get "http://www.minitrue.gov.uk#{path}"
      end

      it_behaves_like 'a 410'
    end

    describe 'parameters without values do not get thrown away' do
      before do
        site.update_attribute(:query_params, "with:a:weird:querystring")

        path           = '/an-archived-page?with&a&weird&querystring'
        canonical_path = '/an-archived-page?a&querystring&weird&with'

        site.mappings.create \
          path:         canonical_path,
          type:         'archive'

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

        it_behaves_like 'a 301'
        its(:location) { should == 'http://r4d.dfid.gov.uk/Output/193679/Default.aspx' }
      end
    end

    describe 'DFID non-www redirects' do
      before do
        site.hosts.create hostname: 'dfid.gov.uk'

        get 'http://dfid.gov.uk/r4d/Output/193679/Default.aspx'
      end

      it_behaves_like 'a 301'
      its(:location) { should == 'http://r4d.dfid.gov.uk/Output/193679/Default.aspx' }
    end

    describe 'DH redirects' do
      let!(:dh_site) {
        department_of_health.sites.create(
            abbr: 'dh',
            tna_timestamp: '2012-10-26 06:52:14',
            homepage: 'https://www.gov.uk/government/organisations/department-of-health',
            homepage_furl: 'www.gov.uk/doh'
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
              type:        'redirect',
              new_url:     'http://www.gov.uk/government/organisations/dh/really-special-asset'

          get 'http://www.dh.gov.uk/dh_digitalassets/really-special-asset'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.gov.uk/government/organisations/dh/really-special-asset' }
      end
    end

    describe 'DH non-www redirects' do
      before { site.hosts.create hostname: 'dh.gov.uk' }

      describe 'visiting a /dh_digitalassets/ URL' do
        before do
          get 'http://dh.gov.uk/a/b/dh_digitalassets/c'
        end

        it_behaves_like 'a 410'
        its(:content_type) { should == 'text/html' }
      end
    end

    describe 'Directgov redirects' do
      before { site.hosts.create hostname: 'www.direct.gov.uk' }

      describe 'visiting a /en search URL' do
        before do
          get 'http://www.direct.gov.uk/a/b/en/AdvancedSearch'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'https://www.gov.uk/search' }
      end

      describe 'visiting a non-/en search URL' do
        before do
          get 'http://www.direct.gov.uk/a/b/AdvancedSearch'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'https://www.gov.uk/search' }
      end

      describe 'visiting a Fire Kills URL' do
        before do
          site.hosts.create hostname: 'campaigns.direct.gov.uk'

          get 'http://campaigns.direct.gov.uk/a/firekills/b'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'https://www.gov.uk/firekills' }
      end
    end

    describe 'Directgov non-www redirects' do
      before { site.hosts.create hostname: 'direct.gov.uk' }

      describe 'visitng a /en search URL' do
        before do
          get 'http://direct.gov.uk/a/b/en/AdvancedSearch'
        end

        it_behaves_like 'a 301'
        its(:location) { should == "https://www.gov.uk/search" }
      end
    end

    describe 'Businesslink redirects' do
      before { site.hosts.create hostname: 'www.businesslink.gov.uk' }

      describe 'visiting a former businesslink site for Wales' do
        before do
          get 'http://www.businesslink.gov.uk/bdotg/action/ercsectorsdetails?r.lc=en&itemid=1077111298&site=230'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://business.wales.gov.uk/bdotg/action/ercsectorsdetails?r.lc=en&itemid=1077111298&site=230' }
      end

      describe 'visiting a former businesslink site for Northern Ireland' do
        before do
          get 'http://www.businesslink.gov.uk/bdotg/action/layer?topicId=1073935899&site=191'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.nibusinessinfo.co.uk/bdotg/action/layer?topicId=1073935899&site=191' }
      end

      describe 'Businesslink URL that shouldn\'t match' do
        before do
          get('http://www.businesslink.gov.uk/bdotg/action/piplink?agency_id=875&service_id=15200011401&site=2000')
        end

        it_behaves_like 'a 404'
        its(:location) { should == nil }
      end
    end

    describe 'Business Link non-www redirects' do
      before { site.hosts.create hostname: 'businesslink.gov.uk' }

      describe 'visiting a former businesslink site for Wales' do
        before do
          get 'http://businesslink.gov.uk/bdotg/action/ercsectorsdetails?r.lc=en&itemid=1077111298&site=230'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://business.wales.gov.uk/bdotg/action/ercsectorsdetails?r.lc=en&itemid=1077111298&site=230' }
      end
    end

    describe 'Environment Agency' do
      before { site.hosts.create hostname: 'www.environment-agency.gov.uk' }

      describe 'Flood Warnings redirects' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/34678.aspx?type=Region&term=Anglian'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/flood/34678.aspx?type=Region&term=Anglian' }
      end

      describe 'Flood Warnings redirects (Welsh)' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/cy/34678.aspx?type=Region&term=Wales&Severity=1'
        end

        it_behaves_like 'a 301'
        its(:location) { should  == 'http://apps.environment-agency.gov.uk/flood/cy/34678.aspx?type=Region&term=Wales&Severity=1' }
      end

      describe 'River Levels redirects' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels/120691.aspx?foo=bar'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels/120691.aspx?foo=bar'}
      end

      describe 'River Levels redirects (Welsh)' do
        before do
          get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels/cy/120691.aspx?foo=bar'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels/cy/120691.aspx?foo=bar' }
      end

      describe 'river levels homepage' do
        describe 'with trailing slash' do
          before do
            get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels/'
          end

          it_behaves_like 'a 301'
          its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels/' }
        end

        describe 'without trailing slash' do
          before do
            get 'http://www.environment-agency.gov.uk/homeandleisure/floods/riverlevels'
          end

          it_behaves_like 'a 301'
          its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels' }
        end
      end

      describe 'overrides any mapping (PreemptiveRules)' do
        before do
          path = '/homeandleisure/floods/34678.aspx?page=1'
          site.mappings.create(path: path, type: 'archive')
          get "http://www.environment-agency.gov.uk#{path}"
        end

        it_behaves_like 'a 301'
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

    describe 'Environment Agency non-www redirects' do
      before { site.hosts.create hostname: 'environment-agency.gov.uk' }

      describe 'river levels homepage without trailing slash' do
        before do
          get 'http://environment-agency.gov.uk/homeandleisure/floods/riverlevels'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://apps.environment-agency.gov.uk/river-and-sea-levels' }
      end
    end

    describe 'Marine Coastguard Agency' do
      before { site.hosts.create hostname: 'www.mcga.gov.uk' }

      describe 'paths beginning with /c4mca/' do
        before do
          get 'http://www.mcga.gov.uk/c4mca/mcga07-home/shipsandcargoes/mcga-shipsregsandguidance.htm'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.dft.gov.uk/mca/mcga07-home/shipsandcargoes/mcga-shipsregsandguidance.htm' }
      end

      describe 'paths beginning with /mca/' do
        before do
          get 'http://www.mcga.gov.uk/mca/msn1693.pdf'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.dft.gov.uk/mca/msn1693.pdf' }
      end

      describe 'all other paths' do
        before do
          get 'http://www.mcga.gov.uk/hydrography'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.dft.gov.uk/mca/hydrography' }
      end
    end

    describe 'Marine Coastguard Agency non-www redirects' do
      before { site.hosts.create hostname: 'mcga.gov.uk' }

      describe 'all paths that aren\'t /mca/ or /c4mca/' do
        before do
          get 'http://mcga.gov.uk/hydrography'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.dft.gov.uk/mca/hydrography' }
      end
    end

    describe 'Number 10 redirects' do
      before { site.hosts.create hostname: 'www.number10.gov.uk' }

      describe 'visiting a news URL' do
        before do
          get 'http://www.number10.gov.uk/news/latest-news/2007/06/Brown-unveils-new-faces-12225'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.number10.gov.uk/news/brown-unveils-new-faces' }
      end
    end

    describe 'Number 10 non-www redirects' do
      before { site.hosts.create hostname: 'number10.gov.uk' }

      describe 'visiting a news URL' do
        before do
          get 'http://number10.gov.uk/news/latest-news/2007/06/Brown-unveils-new-faces-12225'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.number10.gov.uk/news/brown-unveils-new-faces' }
      end
    end

    describe 'Ofsted inspection reports redirects' do
      before { site.hosts.create hostname: 'www.ofsted.gov.uk' }

      describe 'visiting a landing page URL' do
        before do
          get 'http://www.ofsted.gov.uk/inspection-reports/find-inspection-report/provider/CARE/EY480906'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://reports.ofsted.gov.uk/inspection-reports/find-inspection-report/provider/CARE/EY480906' }
      end

      describe 'visiting a report asset URL' do
        before do
          get 'http://www.ofsted.gov.uk/provider/files/1908405/urn/137739.pdf'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://reports.ofsted.gov.uk/provider/files/1908405/urn/137739.pdf' }
      end

      describe 'visiting an interstitial asset download URL' do
        before do
          get 'http://www.ofsted.gov.uk/index.php?q=filedownloading&id=2150035&type=1&refer=0'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://reports.ofsted.gov.uk/index.php?q=filedownloading&id=2150035&type=1&refer=0' }
      end

      describe 'visiting an oxedu provider report page URL' do
        before do
          get 'http://www.ofsted.gov.uk/oxedu_providers/full/(urn)/136338'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://reports.ofsted.gov.uk/inspection-reports/find-inspection-report/provider/ELS/136338' }
      end

      describe 'visiting an oxcare provider report page URL' do
        before do
          get 'http://www.ofsted.gov.uk/oxcare_providers/full/(urn)/EY333119/(type)/33/(typename)/Childcare%20on%20Non-Domestic%20Premises'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://reports.ofsted.gov.uk/inspection-reports/find-inspection-report/provider/CARE/EY333119' }
      end

    end

    describe 'Ofsted inspection reports non-www redirects' do
      before { site.hosts.create hostname: 'ofsted.gov.uk' }

      describe 'visiting a report asset URL' do
        before do
          get 'http://ofsted.gov.uk/provider/files/1908405/urn/137739.pdf'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://reports.ofsted.gov.uk/provider/files/1908405/urn/137739.pdf' }
      end

    end

    describe 'GDS blog redirects' do
      before { site.hosts.create hostname: 'digital.cabinetoffice.gov.uk' }

      describe 'visiting a /* URL' do
        before do
          get 'http://digital.cabinetoffice.gov.uk/tag/david-mann'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'https://gds.blog.gov.uk/tag/david-mann' }
      end
    end

    describe 'GovStore/CloudStore fallback rules' do
      before { site.hosts.create hostname: 'govstore.service.gov.uk' }

      context 'visiting a /cloudstore/service-id URL' do
        before do
          get 'http://govstore.service.gov.uk/cloudstore/5-g5-0722-028'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.digitalmarketplace.service.gov.uk/service/5-g5-0722-028' }
      end

      context 'visiting a /cloudstore/category/service-id URL' do
        before do
          get 'http://govstore.service.gov.uk/cloudstore/scs/5-g5-0722-028'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.digitalmarketplace.service.gov.uk/service/5-g5-0722-028' }
      end

      context 'visiting a /cloudstore/category/sub-category/service-id URL' do
        before do
          get 'http://govstore.service.gov.uk/cloudstore/iaas/sub-category/5-g5-0722-028'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.digitalmarketplace.service.gov.uk/service/5-g5-0722-028' }
      end

      context 'visiting a /cloudstore/category/sub-category/sub-sub-category/service-id URL' do
        before do
          get 'http://govstore.service.gov.uk/cloudstore/iaas/sub-category/sub-sub-category/5-g5-0722-028'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'http://www.digitalmarketplace.service.gov.uk/service/5-g5-0722-028' }
      end

      context 'visiting a GovStore URL that isn\'t for a supplier in a category or within /cloudstore' do
        before do
          get 'http://govstore.service.gov.uk/a'
        end

        it_behaves_like 'a 301'
        its(:location) { should == 'https://www.gov.uk/digital-marketplace' }
      end
    end
  end
end
