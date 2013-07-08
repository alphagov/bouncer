require 'spec_helper'

require 'record_collection'

describe RecordCollection do
  describe '.new' do
    let(:records) { [double, double, double] }
    subject { RecordCollection.new(records) }

    it { should have(3).records }
  end

  describe '#<<' do
    let(:records) { [double, double, double] }
    let(:extra_record) { double 'extra record' }
    subject { RecordCollection.new(records) }

    specify do
      subject.should have(3).records
      subject << extra_record
      subject.should have(4).records
    end
  end

  describe '#size' do
    let(:records) { double 'records' }
    subject { RecordCollection.new(records) }

    before(:each) do
      records.stub size: 7
    end

    specify do
      records.should_receive(:size).with(no_args)
      subject.size
    end

    its(:size) { should == 7 }
  end

  describe '#include?' do
    let(:records) { double 'records' }
    let(:record) { double 'record' }
    subject { RecordCollection.new(records) }

    specify do
      records.should_receive(:include?).with(record)
      subject.include?(record)
    end

    context 'when the collection includes the record' do
      before(:each) do
        records.stub include?: true
      end

      it { should include record }
    end

    context 'when the collection doesn\'t include the record' do
      before(:each) do
        records.stub include?: false
      end

      it { should_not include record }
    end
  end

  describe '#find_by' do
    let(:first_value) { double 'first value' }
    let(:second_value) { double 'second value' }
    let(:first_record) { double 'first record' }
    let(:second_record) { double 'second record' }
    subject { RecordCollection.new([first_record, second_record]) }

    before(:each) do
      first_record.stub(:[]).with(:value).and_return(first_value)
      second_record.stub(:[]).with(:value).and_return(second_value)
    end

    specify { subject.find_by(value: first_value).should == first_record }
    specify { subject.find_by(value: second_value).should == second_record }
  end
end
