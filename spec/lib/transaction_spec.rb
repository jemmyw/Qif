require 'spec_helper'

describe Qif::Transaction do
  describe '#to_s' do
    before do
      @instance = Qif::Transaction.new(
        :date => Time.mktime(2010, 1, 2),
        :amount => -10.0,
        :category => 'Debit',
        :memo => 'Supermarket',
        :payee => 'abcde'
      )
    end
    
    it 'should format the date in the format specified as D' do
      @instance.to_s('dd/mm/yyyy').should include('D02/01/2010')
      @instance.to_s('mm/dd/yyyy').should include('D01/02/2010')
    end
    
    it 'should put the amount in T' do
      @instance.to_s.should include('T-10.00')
    end
    
    it 'should put the category in L' do
      @instance.to_s.should include('LDebit')
    end
    
    it 'should put the description in M' do
      @instance.to_s.should include('MSupermarket')
    end
    
    it 'should put the reference in P' do
      @instance.to_s.should include('Pabcde')
    end
  end
end
