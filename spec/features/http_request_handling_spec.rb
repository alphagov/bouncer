require 'spec_helper'

require 'digest/sha1'
require 'rack/test'
require 'bouncer'
require 'site'

describe 'HTTP request handling' do
  include Rack::Test::Methods

  let(:app) { Bouncer.new }
  let(:organisation) { Organisation.create homepage: 'http://www.gov.uk/government/organisations/ministry-of-truth', title: 'Ministry of Truth', css: 'ministry-of-truth', furl: 'www.gov.uk/mot' }
  let!(:site) { organisation.sites.create(tna_timestamp: '2012-10-26 06:52:14').tap { |site| site.hosts.create host: 'www.minitrue.gov.uk' } }

  specify 'visiting a URL which has been redirected' do
    site.mappings.create \
      path:         '/a-redirected-page',
      path_hash:    Digest::SHA1.hexdigest('/a-redirected-page'),
      http_status:  '301',
      new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

    get 'http://www.minitrue.gov.uk/a-redirected-page'
    last_response.should be_redirect
    last_response.status.should == 301
    last_response.location.should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
  end

  specify 'visiting a URL with query parameters which has been redirected' do
    site.mappings.create \
      path:         '/a-redirected-page?p=np',
      path_hash:    Digest::SHA1.hexdigest('/a-redirected-page?p=np'),
      http_status:  '301',
      new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

    get 'http://www.minitrue.gov.uk/a-redirected-page?p=np'
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

  specify 'visiting an unrecognised host' do
    get 'http://www.minipax.gov.uk/an-unrecognised-page'
    last_response.should be_not_found
    last_response.body.should include '<title>404 - Not Found</title>'
  end
end
