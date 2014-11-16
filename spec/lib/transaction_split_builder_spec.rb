require 'spec_helper'
require 'qif/transaction/split/builder'

describe Qif::Transaction::Split::Builder do
  let(:parent) { double(Qif::Transaction::Builder) }
  let(:builder) { Qif::Transaction::Split::Builder.new(parent) }
  def do_build
    builder.build_split
  end

  context '#add_split' do
    it 'should call add_split on the parent' do
      expect(parent).to receive(:add_split).with("12345")
      described_class.new(parent).add_split("12345")
    end

    it 'should return the new split builder' do
      new_builder = double("split-builder")
      allow(parent).to receive(:add_split).and_return(new_builder)
      expect(described_class.new(parent).add_split(anything)).to eq(new_builder)
    end
  end

  context '#set_memo' do
    it_should_behave_like "builder method", :memo, 'Split', :set_split_memo
  end

  context '#set_amount' do
    it_should_behave_like "builder method", :amount, '-10,000', :set_split_amount, -10000
  end

  context '#set_category' do
    it_should_behave_like 'builder method', :category, '[Cash]', :set_split_category
  end

  context "when receiving an unknown message" do
    it "should pass the message to the parent" do
      expect(parent).to receive(:set_date).with('2012-12-31')
      builder.set_date('2012-12-31')
    end

    it 'should return the result of the message' do
      allow(parent).to receive(:set_date).and_return(parent)
      expect(builder.set_date(anything)).to eq(parent)
    end
  end
end