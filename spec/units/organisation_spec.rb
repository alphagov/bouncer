require "spec_helper"

describe Organisation do
  describe ".create" do
    let(:attributes) { double "attributes" }
    let(:organisation) { double "organisation", save: true }

    before do
      allow(described_class).to receive_messages new: organisation
    end

    specify { expect(described_class.create(attributes)).to eq(organisation) }

    specify do
      expect(described_class).to receive(:new).with(attributes)
      described_class.create(attributes)
    end
  end
end
