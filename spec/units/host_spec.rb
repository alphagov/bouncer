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
    let(:hostname) { double 'hostname' }

    subject { Host.new host: hostname }

    it { should be_a Host }
    its(:host) { should == hostname }
  end
end
