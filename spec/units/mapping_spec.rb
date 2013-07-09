require 'spec_helper'

require 'mapping'

describe Mapping do
  describe '.create' do
    let(:attributes) { double 'attributes' }
    let(:mapping) { double 'mapping' }

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
    let(:http_status) { double 'HTTP status' }
    let(:new_url) { double 'new URL' }

    subject { Mapping.new path: path, path_hash: path_hash, http_status: http_status, new_url: new_url }

    it { should be_a Mapping }
    its(:path) { should == path }
    its(:path_hash) { should == path_hash }
    its(:http_status) { should == http_status }
    its(:new_url) { should == new_url }
  end
end
