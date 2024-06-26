require "spec_helper"

describe Bouncer::CanonicalizedRequest do
  include Rack::Test::Methods

  describe "valid?" do
    let(:env) { "foo" }

    it "returns true if valid URI passed" do
      canonicalized_request = described_class.new(env)
      allow(canonicalized_request).to receive(:bluri).and_return(instance_double(Rack::Request))
      expect(canonicalized_request.valid?).to be(true)
    end

    it "returns false if invalid URI passed" do
      canonicalized_request = described_class.new(env)
      allow(canonicalized_request).to receive(:bluri).and_raise(Addressable::URI::InvalidURIError)
      expect(canonicalized_request.valid?).to be(false)
    end
  end
end
