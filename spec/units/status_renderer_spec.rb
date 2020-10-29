require "spec_helper"

describe StatusRenderer do
  subject(:renderer) { described_class.new }

  describe "template storage" do
    describe "[404]" do
      subject { super()[404] }

      it { is_expected.to be_an(Erubis::EscapedEruby) }
    end

    describe "[410]" do
      subject { super()[410] }

      it { is_expected.to be_an(Erubis::EscapedEruby) }
    end

    describe "[301]" do
      subject { super()[301] }

      it { is_expected.to be_nil }
    end

    it "reuses its templates" do
      t1 = renderer[404]
      t2 = renderer[404]

      expect(t1.object_id).to eq(t2.object_id)
    end
  end

  describe "template rendering" do
    subject(:rendered) { renderer.render(attributes_for_render, 410) }

    let(:attributes_for_render) do
      {
        title: "Keeping bees",
        homepage: nil,
        css: nil,
        furl: nil,
        host: nil,
        suggested_url: nil,
        archive_url: nil,
      }
    end

    it { is_expected.to include("410 - Page Archived") }
    it { is_expected.to include("Keeping bees") }
  end
end
