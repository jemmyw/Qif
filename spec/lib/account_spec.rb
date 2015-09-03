require 'spec_helper'

describe Qif::Account do
  describe '#to_s' do
    before do
      @instance = Qif::Account.new(
        :name => 'Expenses:Eating and Drinking:Coffee',
        :type => 'Expense',
        :description => 'bean counting'
      )
    end
    
    it 'should put the name in N' do
      @instance.to_s.should include('NExpenses:Eating and Drinking:Coffee')
    end

    it 'should put the type in T' do
      @instance.to_s.should include('TExpense')
    end
    
    it 'should put the description in D' do
      @instance.to_s.should include('Dbean counting')
    end
  end
end
