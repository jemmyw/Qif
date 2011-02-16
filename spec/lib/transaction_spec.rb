require 'spec/spec_helper'

describe Qif::Transaction do
  describe '::read' do
    it 'should return a new transaction with all attributes set' do
      t = Qif::Transaction.read(
        'D' => Time.parse('06/ 1/94'),
        'T' => '-1000.00'.to_f,
        'C' => 'X',
        'N' => '1005',
        'P' => 'Bank Of Mortgage',
        'M' => 'aMemo',
        'L' => 'aCategory',
# TODO Support correctly splits with an array of hash
#        'S' => '[linda]
#Mort Int',
#        'E' => 'Cash',
#        '$' => '-253.64
#=746.36',
        'A' => 'P.O. Box 27027
Tucson, AZ
85726',
        '^' => nil
      )

      t.should be_a(Qif::Transaction)
      t.date.should == Time.mktime(1994,6,1)
      t.amount.should == -1000.00
      t.status.should == 'X'
      t.number.should == '1005'
      t.payee.should == 'Bank Of Mortgage'
      t.memo.should == 'aMemo'
      t.category.should == 'aCategory'
      t.adress.should == 'P.O. Box 27027
Tucson, AZ
85726'
    end
    
    it 'should return nil if the date does not respond to strftime' do
      Qif::Transaction.read('D' => 'hello').should be_nil
    end
  end
  
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
