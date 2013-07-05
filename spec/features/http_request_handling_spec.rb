require 'spec_helper'

require 'rack/test'
require 'bouncer'

describe 'HTTP request handling' do
  include Rack::Test::Methods

  let(:app) { Bouncer.new }
  let(:site) { Site.create.tap { |site| site.create_host host: 'www.minitrue.gov.uk' } }

  before(:each) do
    Host.destroy_all
  end

  specify 'visiting a URL which has been redirected' do
    site.create_mapping \
      path:         '/a-redirected-page',
      http_status:  '301',
      new_url:      'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'

    get 'http://www.minitrue.gov.uk/a-redirected-page'
    last_response.should be_redirect
    last_response.status.should == 301
    last_response.location.should == 'http://www.gov.uk/government/organisations/ministry-of-truth/a-redirected-page'
  end

  specify 'visiting a URL which has been archived' do
    site.create_mapping \
      path:         '/an-archived-page',
      http_status:  '410'

    get 'http://www.minitrue.gov.uk/an-archived-page'
    last_response.should be_client_error
    last_response.status.should == 410
  end
end
