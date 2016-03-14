require 'spec_helper'

describe Organisation do
  describe '.create' do
    let(:attributes) { double 'attributes' }
    let(:organisation) { double 'organisation', save: true }

    before(:each) do
      allow(Organisation).to receive_messages new: organisation
    end

    specify { expect(Organisation.create(attributes)).to eq(organisation) }

    specify do
      expect(Organisation).to receive(:new).with(attributes)
      Organisation.create(attributes)
    end
  end
end
