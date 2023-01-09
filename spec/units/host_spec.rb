require "spec_helper"

describe Host do
  describe ".create" do
    let(:attributes) { double "attributes" }
    let(:host) { double "host", save: true }

    before do
      allow(described_class).to receive_messages new: host
    end

    specify { expect(described_class.create(attributes)).to eq(host) }

    specify do
      expect(described_class).to receive(:new).with(attributes)
      described_class.create(attributes)
    end
  end

  describe ".new" do
    subject { described_class.new site:, hostname: }

    let(:site) { Site.new }
    let(:hostname) { "host.name" }

    it { is_expected.to be_a described_class }

    describe "#site" do
      subject { super().site }

      it { is_expected.to eq(site) }
    end

    describe "#hostname" do
      subject { super().hostname }

      it { is_expected.to eq(hostname) }
    end
  end

  describe ".find_by" do
    let(:hostname) { "www.minitrue.gov.uk" }
    let(:other_hostname) { "www.minipax.gov.uk" }
    let!(:host) { described_class.create hostname:, site_id: 321 }

    before do
      described_class.create hostname: other_hostname, site_id: 123
    end

    specify { expect(described_class.find_by(hostname:)).to eq(host) }
  end
end
