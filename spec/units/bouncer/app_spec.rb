require "spec_helper"

describe Bouncer::App do
  include Rack::Test::Methods

  def app
    described_class.new
  end

  let(:hostname)  { "example.com" }
  let(:path)      { "/an-interesting-page" }
  let(:url)       { "http://#{hostname}#{path}" }

  before do
    stub_const "Host", double
    allow(Host).to receive_messages find_by: host
  end

  shared_examples "a redirector" do
    it "responds to requests" do
      expect { get url }.not_to raise_error
    end

    it "tries to find the right host" do
      expect(Host).to receive(:find_by).with(hostname: hostname)
      get url
    end

    it "responds with the correct status code" do
      get url
      expect(last_response.status).to eq(status_code)
    end
  end

  context "when the host is recognised" do
    let(:host)         { double("host").as_null_object }
    let(:organisation) { double("organisation").as_null_object }
    let(:site)         { double("site").as_null_object }
    let(:mappings)     { double "mappings" }

    before do
      allow(host).to receive_messages site: site
      allow(site).to receive_messages mappings: mappings,
                                      query_params: nil,
                                      global_type: nil,
                                      organisation: organisation,
                                      tna_timestamp: nil
      allow(mappings).to receive_messages find_by: mapping
      allow(mappings).to receive_messages first: mapping
    end

    shared_examples "a redirector which recognises the host" do
      it_behaves_like "a redirector"

      it "gets the host's site" do
        expect(host).to receive(:site).with(no_args)
        get url
      end

      it "gets the site's mappings" do
        expect(site).to receive(:mappings).with(no_args)
        get url
      end

      it "tries to find the right mapping" do
        expect(mappings).to receive(:find_by).with(path: path)
        get url
      end
    end

    context "when the path is recognised" do
      let(:mapping) { double "mapping" }

      before do
        allow(mapping).to receive_messages type: type
      end

      shared_examples "a redirector which recognises the host and path" do
        it_behaves_like "a redirector which recognises the host"

        it "gets the mapping's type" do
          expect(mapping).to receive(:type).with(no_args)
          get url
        end
      end

      context "when the URL has been redirected" do
        let(:type)        { "redirect" }
        let(:status_code) { 301 }
        let(:new_url)     { "http://www.gov.uk" }

        before do
          allow(mapping).to receive_messages new_url: new_url
        end

        it_behaves_like "a redirector which recognises the host and path"

        it "gets the mapping's new URL" do
          expect(mapping).to receive(:new_url).with(no_args)
          get url
        end

        it "responds with a redirect" do
          get url
          expect(last_response).to be_redirect
        end

        it "redirects to the new URL" do
          get url
          expect(last_response.location).to eq(new_url)
        end

        context "when the host is aka-" do
          let(:hostname)           { "aka-example.com" }
          let(:rewritten_hostname) { "example.com" }

          it "writes out the aka" do
            expect(Host).to receive(:find_by).with(hostname: rewritten_hostname)
            get url
          end
        end
      end

      context "when the URL has been archived" do
        let(:type)        { "archive" }
        let(:status_code) { 410 }

        it_behaves_like "a redirector which recognises the host and path"

        it "responds with a client error" do
          get url
          expect(last_response).to be_client_error
        end
      end

      context "when the URL is unresolved" do
        let(:type)        { "unresolved" }
        let(:status_code) { 410 }

        it_behaves_like "a redirector which recognises the host and path"

        it "responds with a client error" do
          get url
          expect(last_response).to be_client_error
        end
      end
    end

    context "when visiting www.direct.gov.uk/__canary__" do
      let(:path)             { "/__canary__" }
      let(:hostname)         { "www.direct.gov.uk" }
      let(:host)             { double("host") }
      let(:whitelisted_host) { double("whitelisted_host") }

      before do
        allow(mappings).to receive_messages first: mapping
        allow(host).to receive(:hostname) { hostname }
        allow(WhitelistedHost).to receive(:first).and_return(whitelisted_host)
      end

      context "when everything is fine" do
        let(:mapping)      { double("mapping") }
        let(:organisation) { double("organisation") }

        it "responds with 200" do
          get url
          expect(last_response.status).to eq(200)
        end
      end

      context "when required tables are empty" do
        context "when there is no Site" do
          let(:mapping)      { double("mapping") }
          let(:organisation) { double("organisation") }
          let(:site)         { nil }

          it "responds with 503" do
            get url
            expect(last_response.status).to eq(503)
          end
        end

        context "when there is no organisation" do
          let(:mapping)      { double "mapping" }
          let(:organisation) { nil }

          it "responds with 503" do
            get url
            expect(last_response.status).to eq(503)
          end
        end

        context "when there is no mapping" do
          let(:mapping)      { nil }
          let(:organisation) { double("organisation") }

          it "responds with 503" do
            get url
            expect(last_response.status).to eq(503)
          end
        end

        context "when there are no WhitelistedHosts" do
          let(:mapping)      { double("mapping") }
          let(:organisation) { double("organisation") }

          before do
            allow(WhitelistedHost).to receive(:first).and_return(nil)
          end

          it "responds with 503" do
            get url
            expect(last_response.status).to eq(503)
          end
        end
      end

      context "when we get an Error from the Database" do
        # This variable needs to be present for the setup in the outer context
        let(:mapping)      { nil }

        context "when ActiveRecord raises an exception when querying Host" do
          it "raises error" do
            allow(Host).to receive(:find_by).and_raise("Database does not exist")

            expect { get url }.to raise_error("Database does not exist")
          end
        end

        context "when ActiveRecord raises an exception when querying Sites" do
          it "raises error" do
            # canonicalising the request queries site before
            # we get to the canary
            allow(host).to receive(:site).and_raise("Database does not exist")

            expect { get url }.to raise_error("Database does not exist")
          end
        end

        context "when ActiveRecord raises an exception when querying WhitelistedHosts" do
          it "responds with 503" do
            allow(WhitelistedHost).to receive(:first).and_raise("Database does not exist")

            get url
            expect(last_response.status).to eq(503)
          end
        end

        context "when ActiveRecord raises an exception when querying Organisation" do
          it "responds with 503" do
            allow(site).to receive(:organisation).and_raise("Database does not exist")

            get url
            expect(last_response.status).to eq(503)
          end
        end

        context "when ActiveRecord raises an exception when querying Mappings" do
          it "responds with 503" do
            allow(site).to receive(:mappings).and_raise("Database does not exist")

            get url
            expect(last_response.status).to eq(503)
          end
        end
      end
    end

    context "when the path is not recognised" do
      let(:mapping)     { nil }
      let(:type)        { "never used" }
      let(:status_code) { 404 }

      it_behaves_like "a redirector which recognises the host"

      it "responds with a not found" do
        get url
        expect(last_response).to be_not_found
      end
    end
  end

  context "when the host is not recognised" do
    let(:host)        { nil }
    let(:type)        { "never used" }
    let(:status_code) { 404 }

    it_behaves_like "a redirector"

    it "responds with a not found" do
      get url
      expect(last_response).to be_not_found
    end
  end

  context "when the host is malformed" do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Bouncer::RequestContext).to receive(:valid?).and_return(false)
      # rubocop:enable RSpec/AnyInstance
    end

    let(:host) { double("host").as_null_object } # value unimportant, but needed for `url` to resolve

    it "responds with the correct status code" do
      get url
      expect(last_response.status).to eq(400)
    end
  end
end
