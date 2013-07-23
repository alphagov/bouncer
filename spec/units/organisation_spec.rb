require 'spec_helper'

require 'organisation'

describe Organisation do
  describe '.create' do
    let(:attributes) { double 'attributes' }
    let(:organisation) { double 'organisation', save: true }

    before(:each) do
      Organisation.stub new: organisation
    end

    specify { Organisation.create(attributes).should == organisation }

    specify do
      Organisation.should_receive(:new).with(attributes)
      Organisation.create(attributes)
    end
  end
end
