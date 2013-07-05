require 'spec_helper'

require 'rack/test'
require 'bouncer'

describe Bouncer do
  include Rack::Test::Methods

  let(:app) { subject }
  let(:host_class) { double 'Host' }
  let(:host) { double 'host' }
  let(:hostname) { 'example.com' }
  let(:path) { '/' }
  let(:url) { "http://#{hostname}#{path}" }
  let(:path_hash) { double }
  let(:site) { double 'site' }
  let(:mappings) { double 'mappings' }
  let(:mapping) { double 'mapping' }

  before(:each) do
    stub_const 'Host', host_class

    host_class.stub find_by: host
    Digest::SHA1.stub hexdigest: path_hash
    host.stub site: site
    site.stub mappings: mappings
    mappings.stub find_by: mapping
    mapping.stub http_status: status_code.to_s
  end

  shared_examples 'a redirector' do
    it 'should respond to requests' do
      expect { get url }.to_not raise_error
    end

    it 'should find the right host' do
      host_class.should_receive(:find_by).with(host: hostname)
      get url
    end

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

    it 'should find the right mapping' do
      mappings.should_receive(:find_by).with(path_hash: path_hash)
      get url
    end

    it 'should get the mapping\'s status code' do
      mapping.should_receive(:http_status).with(no_args)
      get url
    end

    it 'should respond with the correct status code' do
      get url
      last_response.status.should == status_code
    end
  end

  context 'when the URL has been archived' do
    let(:status_code) { 410 }

    it_should_behave_like 'a redirector'

    it 'should respond with a client error' do
      get url
      last_response.should be_client_error
    end
  end
end
