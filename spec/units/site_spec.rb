require 'spec_helper'

describe Site do
  describe '.create' do
    let(:site) { double 'site', save: true }

    before(:each) do
      allow(Site).to receive_messages new: site
    end

    specify { expect(Site.create).to eq(site) }

    specify do
      expect(Site).to receive(:new).with(nil)
      Site.create
    end
  end
end
