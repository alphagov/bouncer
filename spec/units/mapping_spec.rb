require "spec_helper"

describe Mapping do
  describe ".create" do
    let(:attributes) { double "attributes" }
    let(:mapping) { double "mapping", save: true }

    before do
      allow(Mapping).to receive_messages new: mapping
    end

    specify { expect(Mapping.create(attributes)).to eq(mapping) }

    specify do
      expect(Mapping).to receive(:new).with(attributes)
      Mapping.create(attributes)
    end
  end

  describe ".new" do
    subject { Mapping.new path: path, type: type, new_url: new_url }

    let(:path) { "path" }
    let(:type) { "type" }
    let(:new_url) { "new URL" }

    it { is_expected.to be_a Mapping }

    describe "#path" do
      subject { super().path }

      it { is_expected.to eq(path) }
    end

    describe "#type" do
      subject { super().type }

      it { is_expected.to eq(type) }
    end

    describe "#new_url" do
      subject { super().new_url }

      it { is_expected.to eq(new_url) }
    end
  end
end
