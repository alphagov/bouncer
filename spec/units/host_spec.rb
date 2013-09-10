require 'spec_helper'

describe Host do
  describe '.create' do
    let(:attributes) { double 'attributes' }
    let(:host) { double 'host', save: true }

    before(:each) do
      Host.stub new: host
    end

    specify { Host.create(attributes).should == host }

    specify do
      Host.should_receive(:new).with(attributes)
      Host.create(attributes)
    end
  end

  describe '.new' do
    let(:site) { Site.new }
    let(:hostname) { double 'hostname' }

    subject { Host.new site: site, hostname: hostname }

    it { should be_a Host }
    its(:site) { should == site }
    its(:hostname) { should == hostname }
  end

  describe '.find_by' do
    let(:hostname) { 'www.minitrue.gov.uk' }
    let(:other_hostname) { 'www.minipax.gov.uk' }

    before(:each) do
      Host.create hostname: other_hostname
      @host = Host.create hostname: hostname
    end

    specify { Host.find_by(hostname: hostname).should == @host }
  end
end
