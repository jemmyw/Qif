require 'spec_helper'

shared_examples_for "3 record files" do
  it 'should have 3 records' do
    instance.size.should == 3
  end

  it 'should have a debit of $10 on the 1st of January 2010' do
    transaction = instance.transactions.detect{|t| t.date == Time.mktime(2010, 1, 1)}
    transaction.should_not be_nil
    transaction.category.should == 'Debit'
    transaction.amount.should == -10.0
  end

  it 'should have a debit of $20 on the 1st of June 1020' do
    transaction = instance.transactions.detect{|t| t.date == Time.mktime(2010, 6, 1)}
    transaction.should_not be_nil
    transaction.category.should == 'Debit'
    transaction.amount.should == -20.0
  end

  it 'should have a credit of $30 on the 29th of December 2010' do
    transaction = instance.transactions.detect{|t| t.date == Time.mktime(2010, 12, 29)}
    transaction.should_not be_nil
    transaction.category.should == 'Credit'
    transaction.amount.should == 30.0
  end

  describe '#each' do
    it 'should yield each transaction' do
      transactions = []
      instance.each do |t|
        transactions << t
      end
      transactions.should == instance.transactions
    end
  end
end

describe Qif::Reader do
  %w(dd/mm/yyyy mm/dd/yyyy dd/mm/yy mm/dd/yy).each do |format|
    context "when format is #{format}" do
      it_behaves_like "3 record files" do
        let(:instance) { Qif::Reader.new(open('spec/fixtures/3_records_%s.qif' % format.gsub('/', '')).read, format) }
      end
    end
  end

  context "it should still work when the record header is followed by an invalid transaction terminator" do
    it_behaves_like "3 record files" do
      let(:instance) { Qif::Reader.new(open('spec/fixtures/3_records_invalid_header.qif'), 'dd/mm/yy') }
    end
  end

  it 'should reject the wrong account type !Type:Invst and raise an UnknownAccountType exception' do
    expect{ Qif::Reader.new(open('spec/fixtures/quicken_investment_account.qif')) }.to raise_error(Qif::Reader::UnknownAccountType)
  end
  it 'should reject the wrong file and raise an UnrecognizedData exception' do
    expect{ Qif::Reader.new(open('spec/fixtures/not_a_QIF_file.txt')) }.to raise_error(Qif::Reader::UnrecognizedData)
  end
  it 'should guess the date format dd/mm/yyyy' do
    @instance = Qif::Reader.new(open('spec/fixtures/3_records_ddmmyyyy.qif'))
    @instance.guess_date_format.should == 'dd/mm/yyyy'
  end

  it 'should guess the date format mm/dd/yy' do
    @instance = Qif::Reader.new(open('spec/fixtures/3_records_mmddyy.qif'))
    @instance.guess_date_format.should == 'mm/dd/yy'
  end

  it 'shouldn\t guess the date format because transactions are ambiguious, fall back on default dd/mm/yyyy and fail' do
    @instance = Qif::Reader.new(open('spec/fixtures/quicken_non_investement_account.qif'))
    @instance.guess_date_format.should == nil
    @instance.size.should == 0
  end
  
# TODO Date parser should be more flexible and efficient, probably using Date.strptime(str, format)
#  it 'should initialize if leading zeros are missing too' do
#    @instance = Qif::Reader.new(open('spec/fixtures/3_records_dmyy.qif'))
#    @instance.size.should == 3
#  end

  it 'should should parse amounts with comma separator too' do
    @instance = Qif::Reader.new(open('spec/fixtures/3_records_separator.qif'))
    @instance.size.should == 3
    @instance.collect(&:amount).should == [-1010.0, -30020.0, 30.0]
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
