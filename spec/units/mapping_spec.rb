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
    let(:path_hash) { double 'path hash' }
    let(:type) { double 'type' }
    let(:new_url) { double 'new URL' }

    subject { Mapping.new path: path, path_hash: path_hash, type: type, new_url: new_url }

    it { should be_a Mapping }
    its(:path) { should == path }
    its(:path_hash) { should == path_hash }
    its(:type) { should == type }
    its(:new_url) { should == new_url }
  end
end
