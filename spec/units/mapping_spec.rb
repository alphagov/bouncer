require 'spec_helper'

describe Mapping do
  describe '.create' do
    let(:attributes) { double 'attributes' }
    let(:mapping) { double 'mapping', save: true }

    before(:each) do
      Mapping.stub new: mapping
    end

    specify { Mapping.create(attributes).should == mapping }

    specify do
      Mapping.should_receive(:new).with(attributes)
      Mapping.create(attributes)
    end
  end

  describe '.new' do
    let(:path) { double 'path' }
    let(:type) { double 'type' }
    let(:new_url) { double 'new URL' }

    subject { Mapping.new path: path, type: type, new_url: new_url }

    it { should be_a Mapping }
    its(:path) { should == path }
    its(:type) { should == type }
    its(:new_url) { should == new_url }
  end
end
