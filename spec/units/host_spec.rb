require 'spec_helper'

require 'host'

describe Host do
  describe '.create' do
    let(:attributes) { double 'attributes' }
    let(:host) { double 'host' }

    before(:each) do
      Host.stub new: host
    end

    specify { Host.create(attributes).should == host }

    specify do
      Host.should_receive(:new).with(attributes)
      Host.create(attributes)
    end
  end
end
