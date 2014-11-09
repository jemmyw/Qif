require 'spec_helper'
require 'qif/transaction/builder'
require 'qif/transaction/split/builder'

describe Qif::Transaction::Builder do
  let(:builder) { Qif::Transaction::Builder.new }
  def split_builder
    double(Qif::Transaction::Split::Builder).tap do |b|
      allow(b).to receive(:set_split_category).and_return(b)
    end
  end
  def do_build
    builder.build
  end

  context '#build' do
    it 'should return a transaction object' do
      expect(builder.build).to be_kind_of(Qif::Transaction)
    end

    context 'with splits' do
      it 'should call build_split on each of the splits' do
        sb1 = split_builder
        sb2 = split_builder
        allow(Qif::Transaction::Split::Builder).to receive(:new).and_return(sb1, sb2)
        expect(sb1).to receive(:build_split).ordered
        expect(sb2).to receive(:build_split).ordered
        builder.add_split("a")
        builder.add_split("b")
        builder.build
      end

      it 'should add the splits to the transaction' do
        builder.add_split("a")
        builder.add_split("b")
        expect(builder.build.splits.count).to eq(2)
      end
    end
  end

 context '#set_date' do
    it_should_behave_like 'builder method', :date, '1994-06-01', :set_date, Time.mktime(1994, 6, 1)
    it 'should use a given date parser' do
      b = Qif::Transaction::Builder.new(->(date) { date })
      b.set_date('1994')
      expect(b.build.date).to eq('1994')
    end
  end

  context '#set_amount' do
    it_should_behave_like 'builder method', :amount, '-1000.00', :set_amount, -1000.0
    it 'should parse commas out of the amount' do
      builder.set_amount('1,000,000')
      expect(builder.build.amount).to eq(1_000_000)
    end
  end

  context '#set_status' do
    it_should_behave_like 'builder method', :status, 'X', :set_status, 'X'
  end

  context '#set_number' do
    it_should_behave_like 'builder method', :number, '1005', :set_number, '1005'
  end

  context '#set_payee' do
    it_should_behave_like 'builder method', :payee, 'Bank of Mortgage', :set_payee, 'Bank of Mortgage'
  end

  context '#set_memo' do
    it_should_behave_like 'builder method', :memo, 'Some stuff that happened', :set_memo, 'Some stuff that happened'
  end

  context '#set_category' do
    it_should_behave_like 'builder method', :category, 'Fishing', :set_category, 'Fishing'
  end

  context '#set_address' do
    address = <<-EOA
      P.O. Box 1234
      Somewhereton
      12345
    EOA
    
    it_should_behave_like 'builder method', :adress, address, :set_adress, address

    context 'when called consecutively' do
      it "should append to the address" do
        builder
          .set_address("Line 1")
          .set_address("Line 2")
        expect(do_build.address).to eq("Line 1\nLine 2")
      end
    end
  end

  context "#add_split" do
    it 'should create a new split builder' do
      expect(Qif::Transaction::Split::Builder).to receive(:new).with(builder).and_return(split_builder)
      builder.add_split("aaa")
    end

    it 'should set the category on the split builder' do
      sb = split_builder
      allow(Qif::Transaction::Split::Builder).to receive(:new).and_return(sb)
      expect(sb).to receive(:set_split_category).with('aaaa')
      builder.add_split('aaaa')
    end

    it "should return a split builder" do
      expect(builder.add_split('aaaa')).to be_kind_of(Qif::Transaction::Split::Builder)
    end

    context "when called multiple times" do
      it "should return multiple different builders" do
        sb1 = builder.add_split("aaaa")
        expect(builder.add_split("bbbb")).to_not eq(sb1)
      end
    end
  end

end
