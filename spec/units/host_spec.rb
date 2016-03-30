require 'spec_helper'

describe Host do
  describe '.create' do
    let(:attributes) { double 'attributes' }
    let(:host) { double 'host', save: true }

    before(:each) do
      allow(Host).to receive_messages new: host
    end

    specify { expect(Host.create(attributes)).to eq(host) }

    specify do
      expect(Host).to receive(:new).with(attributes)
      Host.create(attributes)
    end
  end

  describe '.new' do
    let(:site) { Site.new }
    let(:hostname) { 'host.name' }

    subject { Host.new site: site, hostname: hostname }

    it { is_expected.to be_a Host }

    describe '#site' do
      subject { super().site }
      it { is_expected.to eq(site) }
    end

    describe '#hostname' do
      subject { super().hostname }
      it { is_expected.to eq(hostname) }
    end
  end

  describe '.find_by' do
    let(:hostname) { 'www.minitrue.gov.uk' }
    let(:other_hostname) { 'www.minipax.gov.uk' }

    before(:each) do
      Host.create hostname: other_hostname, site_id: 123
      @host = Host.create hostname: hostname, site_id: 321
    end

    specify { expect(Host.find_by(hostname: hostname)).to eq(@host) }
  end
end
