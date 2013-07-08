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

  describe '.new' do
    let(:site) { double 'site' }
    let(:hostname) { double 'hostname' }

    subject { Host.new site: site, host: hostname }

    it { should be_a Host }
    its(:site) { should == site }
    its(:host) { should == hostname }
  end

  describe '.find_by' do
    let(:hostname) { double 'hostname' }
    let(:other_hostname) { double 'other hostname' }

    before(:each) do
      Host.destroy_all # to avoid hosts leaking in from other specs
      Host.create host: other_hostname
      @host = Host.create host: hostname
    end

    specify { Host.find_by(host: hostname).should == @host }
  end
end
