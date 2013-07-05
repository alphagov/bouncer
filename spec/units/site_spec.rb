require 'spec_helper'

require 'site'

describe Site do
  describe '.create' do
    let(:site) { double 'site' }

    before(:each) do
      Site.stub new: site
    end

    specify { Site.create.should == site }

    specify do
      Site.should_receive(:new).with(no_args)
      Site.create
    end
  end
end
