require 'spec_helper'

describe Site do
  describe '.create' do
    let(:site) { double 'site', save: true }

    before(:each) do
      Site.stub new: site
    end

    specify { Site.create.should == site }

    specify do
      Site.should_receive(:new).with(nil)
      Site.create
    end
  end
end
