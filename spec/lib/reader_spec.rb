require File.expand_path('../../spec_helper', __FILE__)

describe Qif::Reader do
  %w(dd/mm/yyyy mm/dd/yyyy dd/mm/yy mm/dd/yy).each do |format|
    before do
      @file = 'spec/fixtures/3_records_%s.qif' % format.gsub('/', '')
      @instance = Qif::Reader.new(open(@file), format)
    end
    
    it 'should have 3 records' do
      @instance.size.should == 3
    end
    
    it 'should have a debit of $10 on the 1st of January 2010' do
      transaction = @instance.transactions.detect{|t| t.date == Time.mktime(2010, 1, 1) || t.date == Time.mktime(10, 1, 1)}
      transaction.should_not be_nil
      transaction.name.should == 'Debit'
      transaction.amount.should == -10.0
    end
    
    it 'should have a debit of $20 on the 1st of June 1020' do
      transaction = @instance.transactions.detect{|t| t.date == Time.mktime(2010, 6, 1) || t.date == Time.mktime(10, 6, 1)}
      transaction.should_not be_nil
      transaction.name.should == 'Debit'
      transaction.amount.should == -20.0
    end
    
    it 'should have a credit of $30 on the 29th of December 2010' do
      transaction = @instance.transactions.detect{|t| t.date == Time.mktime(2010, 12, 29) || t.date == Time.mktime(10, 12, 29)}
      transaction.should_not be_nil
      transaction.name.should == 'Credit'
      transaction.amount.should == 30.0
    end
    
    describe '#each' do
      it 'should yield each transaction' do
        transactions = []
        @instance.each do |t|
          transactions << t
        end
        transactions.should == @instance.transactions
      end
    end
  end
  
  it 'should initialize with an io object' do
    @instance = Qif::Reader.new(open('spec/fixtures/3_records_ddmmyyyy.qif'))
    @instance.size.should == 3
  end
  
  it 'should initialize with data in a string' do
    @instance = Qif::Reader.new(File.read('spec/fixtures/3_records_ddmmyyyy.qif'))
    @instance.size.should == 3
  end
  
  it 'should reject transactions whose date does not match the given date format' do
    @instance = Qif::Reader.new(open('spec/fixtures/3_records_ddmmyyyy.qif'), 'mm/dd/yyyy')
    @instance.size.should == 2
  end
end