require 'spec_helper'

##
# Assume that test URLs have been through c14n
# in middleware. Test accordingly, e.g. /my-path, not /my-path///, http not https, etc.
# See +URI::BLURI.canonicalize!+ for rules
describe Bouncer::App do
  include Rack::Test::Methods

  let(:app)       { subject }
  let(:hostname)  { 'example.com' }
  let(:path)      { '/an-interesting-page' }
  let(:url)       { "http://#{hostname}#{path}" }

  before(:each) do
    stub_const 'Host', double
    Host.stub find_by: host
  end

  shared_examples 'a redirector' do
    it 'should respond to requests' do
      expect { get url }.to_not raise_error
    end

    it 'should try to find the right host' do
      Host.should_receive(:find_by).with(host: hostname)
      get url
    end

    it 'should respond with the correct status code' do
      get url
      last_response.status.should == status_code
    end
  end

  context 'when the host is recognised' do
    let(:host) { double 'host' }
    let(:path_hash) { double 'path hash' }
    let(:site) { double 'site' }
    let(:mappings) { double 'mappings' }

    before(:each) do
      Digest::SHA1.stub hexdigest: path_hash
      host.stub site: site
      site.stub mappings: mappings
      mappings.stub find_by: mapping
    end

    shared_examples 'a redirector which recognises the host' do
      it_should_behave_like 'a redirector'

      it 'should hash the path' do
        Digest::SHA1.should_receive(:hexdigest).with(path)
        get url
      end

      it 'should get the host\'s site' do
        host.should_receive(:site).with(no_args)
        get url
      end

      it 'should get the site\'s mappings' do
        site.should_receive(:mappings).with(no_args)
        get url
      end

      it 'should try to find the right mapping' do
        mappings.should_receive(:find_by).with(path_hash: path_hash)
        get url
      end
    end

    context 'when the path is recognised' do
      let(:mapping) { double 'mapping' }

      before(:each) do
        mapping.stub http_status: status_code.to_s
      end

      shared_examples 'a redirector which recognises the host and path' do
        it_should_behave_like 'a redirector which recognises the host'

        it 'should get the mapping\'s status code' do
          mapping.should_receive(:http_status).with(no_args)
          get url
        end
      end

      context 'when the URL has been redirected' do
        let(:status_code) { 301 }
        let(:new_url) { "http://www.gov.uk" }

        before(:each) do
          mapping.stub new_url: new_url
        end

        it_should_behave_like 'a redirector which recognises the host and path'

        it 'should get the mapping\'s new URL' do
          mapping.should_receive(:new_url).with(no_args)
          get url
        end

        it 'should respond with a redirect' do
          get url
          last_response.should be_redirect
        end

        it 'should redirect to the new URL' do
          get url
          last_response.location.should == new_url
        end
      end

      context 'when the URL has been archived' do
        let(:status_code) { 410 }

        it_should_behave_like 'a redirector which recognises the host and path'

        it 'should respond with a client error' do
          get url
          last_response.should be_client_error
        end
      end
    end

    context 'when the path is not recognised' do
      let(:mapping) { nil }
      let(:status_code) { 404 }

      it_should_behave_like 'a redirector which recognises the host'

      it 'should respond with a not found' do
        get url
        last_response.should be_not_found
      end
    end
  end

  context 'when the host is not recognised' do
    let(:host) { nil }
    let(:status_code) { 404 }

    it_should_behave_like 'a redirector'

    it 'should respond with a not found' do
      get url
      last_response.should be_not_found
    end
  end
end
