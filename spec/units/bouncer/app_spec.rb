require 'spec_helper'

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
      Host.should_receive(:find_by).with(hostname: hostname)
      get url
    end

    it 'should respond with the correct status code' do
      get url
      last_response.status.should == status_code
    end
  end

  context 'when the host is recognised' do
    let(:host)         { double('host').as_null_object }
    let(:organisation) { double('organisation').as_null_object }
    let(:site)         { double('site').as_null_object }
    let(:mappings)     { double 'mappings' }

    before(:each) do
      host.stub site: site
      site.stub mappings: mappings,
                query_params: nil,
                global_type: nil,
                organisation: organisation,
                tna_timestamp: nil
      mappings.stub find_by: mapping
      mappings.stub first: mapping
    end

    shared_examples 'a redirector which recognises the host' do
      it_should_behave_like 'a redirector'

      it 'should get the host\'s site' do
        host.should_receive(:site).with(no_args)
        get url
      end

      it 'should get the site\'s mappings' do
        site.should_receive(:mappings).with(no_args)
        get url
      end

      it 'should try to find the right mapping' do
        mappings.should_receive(:find_by).with(path: path)
        get url
      end
    end

    context 'when the path is recognised' do
      let(:mapping) { double 'mapping' }

      before(:each) do
        mapping.stub type: type
      end

      shared_examples 'a redirector which recognises the host and path' do
        it_should_behave_like 'a redirector which recognises the host'

        it 'should get the mapping\'s type' do
          mapping.should_receive(:type).with(no_args)
          get url
        end
      end

      context 'when the URL has been redirected' do
        let(:type)        { 'redirect' }
        let(:status_code) { 301 }
        let(:new_url)     { "http://www.gov.uk" }

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

        context 'when the host is aka-' do
          let(:hostname)           { 'aka-example.com'}
          let(:rewritten_hostname) { 'example.com'}

          it 'writes out the aka' do
            Host.should_receive(:find_by).with(hostname: rewritten_hostname)
            get url
          end
        end
      end

      context 'when the URL has been archived' do
        let(:type)        { 'archive' }
        let(:status_code) { 410 }

        it_should_behave_like 'a redirector which recognises the host and path'

        it 'should respond with a client error' do
          get url
          last_response.should be_client_error
        end
      end

      context 'when the URL is unresolved' do
        let(:type)        { 'unresolved' }
        let(:status_code) { 410 }

        it_should_behave_like 'a redirector which recognises the host and path'

        it 'should respond with a client error' do
          get url
          last_response.should be_client_error
        end
      end
    end

    context 'when visiting www.direct.gov.uk/__canary__' do
      let(:path)             { '/__canary__' }
      let(:hostname)         { 'www.direct.gov.uk' }
      let(:host)             { double('host') }
      let(:whitelisted_host) { double('whitelisted_host')}

      before(:each) do
        mappings.stub first: mapping
        host.stub(:hostname) { hostname }
        WhitelistedHost.stub(:first).and_return(whitelisted_host)
      end

      context 'when everything is fine' do
        let(:mapping)      { double('mapping') }
        let(:organisation) { double('organisation') }

        it 'responds with 200' do
          get url
          last_response.status.should == 200
        end
      end

      context 'when required tables are empty' do
        context 'when there is no Site' do
          let(:mapping)      { double('mapping') }
          let(:organisation) { double('organisation') }
          let(:site)         { nil }

          it 'should respond with 503' do
            get url
            last_response.status.should == 503
          end
        end

        context 'when there is no organisation' do
          let(:mapping)      { double 'mapping' }
          let(:organisation) { nil }

          it 'should respond with 503' do
            get url
            last_response.status.should == 503
          end
        end

        context 'when there is no mapping' do
          let(:mapping)      { nil }
          let(:organisation) { double('organisation') }

          it 'should respond with 503' do
            get url
            last_response.status.should == 503
          end
        end

        context 'when there are no WhitelistedHosts' do
          let(:mapping)      { double('mapping') }
          let(:organisation) { double('organisation') }

          before do
            WhitelistedHost.stub(:first).and_return(nil)
          end

          it 'should respond with 503' do
            get url
            last_response.status.should == 503
          end
        end
      end

      context 'when we get an Error from the Database' do
        # This variable needs to be present for the setup in the outer context
        let(:mapping)      { nil }

        context 'when ActiveRecord raises an exception when querying Host' do
          it 'should raise error' do
            Host.stub(:find_by).and_raise('Database does not exist')

            expect { get url }.to raise_error
          end
        end

        context 'when ActiveRecord raises an exception when querying Sites' do
          it 'should raise error' do

            # canonicalising the request queries site before
            # we get to the canary
            host.stub(:site).and_raise('Database does not exist')

            expect { get url }.to raise_error
          end
        end

        context 'when ActiveRecord raises an exception when querying WhitelistedHosts' do
          it 'should respond with 503' do
            WhitelistedHost.stub(:first).and_raise('Database does not exist')

            get url
            last_response.status.should == 503
          end
        end

        context 'when ActiveRecord raises an exception when querying Organisation' do
          it 'should respond with 503' do
            site.stub(:organisation).and_raise('Database does not exist')

            get url
            last_response.status.should == 503
          end
        end

        context 'when ActiveRecord raises an exception when querying Mappings' do
          it 'should respond with 503' do
            site.stub(:mappings).and_raise('Database does not exist')

            get url
            last_response.status.should == 503
          end
        end
      end
    end

    context 'when the path is not recognised' do
      let(:mapping)     { nil }
      let(:type)        { 'never used' }
      let(:status_code) { 404 }

      it_should_behave_like 'a redirector which recognises the host'

      it 'should respond with a not found' do
        get url
        last_response.should be_not_found
      end
    end
  end

  context 'when the host is not recognised' do
    let(:host)        { nil }
    let(:type)        { 'never used' }
    let(:status_code) { 404 }

    it_should_behave_like 'a redirector'

    it 'should respond with a not found' do
      get url
      last_response.should be_not_found
    end
  end
end
