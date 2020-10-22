require "spec_helper"

describe Site do
  describe ".create" do
    let(:site) { double "site", save: true }

    before do
      allow(described_class).to receive_messages new: site
    end

    specify { expect(described_class.create).to eq(site) }

    specify do
      expect(described_class).to receive(:new).with(nil)
      described_class.create
    end
  end
end
