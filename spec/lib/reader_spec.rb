require 'spec_helper'

shared_examples_for "3 record files" do
  it 'should have 3 records' do
    instance.size.should == 3
  end

  it 'should have a debit of $10 on the 1st of January 2010' do
    transaction = instance.transactions.detect{|t| t.date == Date.new(2010, 1, 1)}
    transaction.should_not be_nil
    transaction.category.should == 'Debit'
    transaction.amount.should == -10.0
  end

  it 'should have a debit of $20 on the 1st of June 1020' do
    transaction = instance.transactions.detect{|t| t.date == Date.new(2010, 6, 1)}
    transaction.should_not be_nil
    transaction.category.should == 'Debit'
    transaction.amount.should == -20.0
  end

  it 'should have a credit of $30 on the 29th of December 2010' do
    transaction = instance.transactions.detect{|t| t.date == Date.new(2010, 12, 29)}
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

  context "when format has spaces" do
    it_behaves_like "3 record files" do
      let(:instance) { Qif::Reader.new(open('spec/fixtures/3_records_spaced.qif').read) }
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

  describe '#guess_date_format' do
    it 'should guess the date format dd/mm/yyyy' do
      @instance = Qif::Reader.new(open('spec/fixtures/3_records_ddmmyyyy.qif'))
      @instance.guess_date_format.should == 'dd/mm/yyyy'
    end

    it 'should guess the date format mm/dd/yy' do
      @instance = Qif::Reader.new(open('spec/fixtures/3_records_mmddyy.qif'))
      @instance.guess_date_format.should == 'mm/dd/yy'
    end

    it 'should fall back to best guess if the date are ambiguious' do
      @instance = Qif::Reader.new(open('spec/fixtures/quicken_non_investement_account.qif'))
      @instance.guess_date_format.should == 'dd/mm/yy'
    end

    it 'should guess the date format d/m/yy' do
      @instance = Qif::Reader.new(open('spec/fixtures/3_records_dmyy.qif'))
      @instance.guess_date_format.should == 'dd/mm/yy'
    end
  end

  it 'should parse amounts with comma separator too' do
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

  context 'when reading splits' do
    let(:reader) { Qif::Reader.new(open('spec/fixtures/splits.qif'), 'd/m/yyyy') }

    context 'the first transaction' do
      let (:transaction) { reader.transactions[0] }

      it 'should have the correct number of splits' do
        expect(transaction.splits.size).to eq(2)
      end

      context 'the first split' do
        let (:split) { transaction.splits.first }

        it { expect(split.category).to eq("[steve]") }
        it { expect(split.memo).to eq("Cash") }
        it { expect(split.amount).to eq(-253.64)}
      end

      context 'the second split' do
        let (:split) { transaction.splits[1] }

        it { expect(split.category).to eq("Mort Int") }
        it { expect(split.amount).to eq(746.36) }
      end

    end

    context "when the transaction has splits first" do
      let(:transaction) { reader.transactions[1] }

      it 'should correctly add the amount to the transaction' do
        expect(transaction.amount).to eq(75)
      end

      it { expect(transaction.splits.first.amount).to eq(23) }
    end
  end

  context "reading account blocks" do
    it 'should parse the account block' do
      @instance = Qif::Reader.new(open('spec/fixtures/quicken_non_investement_account_with_account_block.qif'))
      account = @instance.transactions.last
      expect(account).to be_a(Qif::Account)
      expect(account.name).to eq("Nice Account")
      expect(account.type).to eq("Bank")
      expect(account.description).to eq("This is a fine account")
    end
  end
end
