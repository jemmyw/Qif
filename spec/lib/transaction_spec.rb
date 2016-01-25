require 'spec_helper'

describe Qif::Transaction do
  describe '#to_s' do
    let(:builder) do
      Qif::Transaction::Builder.new
        .set_date(Time.mktime(2010, 1, 2).to_s)
        .set_amount('-10.0')
        .set_category('Debit')
        .set_memo('Supermarket')
        .set_payee('abcde')
    end

    let(:txn) do
      builder.build
    end

    subject { txn.to_s }

    it 'should format the date in the format specified as D' do
      expect(txn.to_s('dd/mm/yyyy')).to include('D02/01/2010')
      expect(txn.to_s('mm/dd/yyyy')).to include('D01/02/2010')
    end
    
    it 'should put the amount in T' do
      expect(subject).to include('T-10.00')
    end
    
    it 'should put the category in L' do
      expect(subject).to include('LDebit')
    end
    
    it 'should put the description in M' do
      expect(subject).to include('MSupermarket')
    end
    
    it 'should put the reference in P' do
      expect(subject).to include('Pabcde')
    end

    it 'adds splits to the output' do
      builder.add_split('split_1')
        .set_split_memo('test split 1')
        .set_split_amount('-5.0')
        .add_split('split_2')
        .set_split_memo('test split 2')
        .set_split_amount('-5.0')

      expect(subject).to include(<<SPLIT.strip)
Ssplit_1
Etest split 1
$-5.00
Ssplit_2
Etest split 2
$-5.0
SPLIT
    end
  end
end
