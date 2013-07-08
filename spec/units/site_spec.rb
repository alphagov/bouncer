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

  describe '#create_mapping' do
    let(:attributes) { double 'attributes' }
    let(:mapping) { double 'mapping' }

    before(:each) do
      stub_const 'Mapping', double
      Mapping.stub create: mapping
    end

    specify { subject.create_mapping(attributes).should == mapping }

    specify do
      Mapping.should_receive(:create).with(attributes)
      subject.create_mapping(attributes)
    end
  end

  describe '#create_host' do
    let(:attributes) { double 'attributes' }
    let(:host) { double 'host' }

    before(:each) do
      stub_const 'Host', double
      Host.stub create: host
    end

    specify { subject.create_host(attributes).should == host }

    specify do
      Host.should_receive(:create).with(attributes)
      subject.create_host(attributes)
    end
  end
end
