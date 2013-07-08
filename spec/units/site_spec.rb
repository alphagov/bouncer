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

  describe '#mappings' do
    let(:first_mapping) { double 'first mapping' }
    let(:first_mapping_attributes) { double 'first mapping attributes' }
    let(:second_mapping) { double 'second mapping' }
    let(:second_mapping_attributes) { double 'second mapping attributes' }

    before(:each) do
      stub_const 'Mapping', double
      Mapping.stub(:create).with(first_mapping_attributes).and_return(first_mapping)
      Mapping.stub(:create).with(second_mapping_attributes).and_return(second_mapping)

      subject.create_mapping first_mapping_attributes
      subject.create_mapping second_mapping_attributes
    end

    it { should have(2).mappings }
    its(:mappings) { should include first_mapping }
    its(:mappings) { should include second_mapping }
  end

  describe '#create_host' do
    let(:hostname) { double 'hostname' }
    let(:attributes) { { host: hostname } }
    let(:host) { double 'host' }

    before(:each) do
      stub_const 'Host', double
      Host.stub create: host
    end

    specify { subject.create_host(attributes).should == host }

    specify do
      Host.should_receive(:create).with(host: hostname, site: subject)
      subject.create_host(attributes)
    end
  end
end
