require 'spec_helper'
require 'stringio'

describe Qif::Writer do
  before do
    @buffer = ''
    @io = StringIO.new(@buffer)
    @instance = Qif::Writer.new(@io)
  end
  
  describe '::open' do
    before do
      @path = '/tmp/test'
      File.stub!(:open).and_yield @io
    end
    
    it 'should yield a Qif::Writer' do
      ran = false
      Qif::Writer.open(@path) do |writer|
        ran = true
        writer.should be_a(Qif::Writer)
      end
      ran.should be_true
    end
    
    it 'should write the transactions' do
      date = Time.now
      
      Qif::Writer.open(@path) do |writer|
        writer << Qif::Transaction.new(:date => date, :amount => 10.0, :category => 'Credit')
      end
      
      @buffer.should include('D%s' % date.strftime('%d/%m/%Y'))
      @buffer.should include('T10.0')
      @buffer.should include('LCredit')
    end
    
    it 'should perform a File.open on the given path' do
      File.should_receive(:open).with(@path, 'w')
      Qif::Writer.open(@path) do |writer|
      end
    end
  end
  describe '::new' do
    it 'should yield a Qif::Writer' do
      ran = false
      Qif::Writer.new(@io) do |writer|
        ran = true
        writer.should be_a(Qif::Writer)
      end
      ran.should be_true
    end
    
    it 'should write the transactions' do
      date = Time.now
      
      Qif::Writer.new(@io) do |writer|
        writer << Qif::Transaction.new(:date => date, :amount => 10.0, :category => 'Credit')
      end
      
      @buffer.should include('D%s' % date.strftime('%d/%m/%Y'))
      @buffer.should include('T10.0')
      @buffer.should include('LCredit')
    end
    
    it 'should perform a File.open on the given path' do
      File.should_receive(:open).with(@path, 'w')
      Qif::Writer.open(@path) do |writer|
      end
    end
  end




  
  describe '#write' do
    it 'should write the header' do
      @instance.write
      @buffer.should include("!Type:Bank\n")
    end
    
    it 'should write any pending transactions' do
      date = Time.now
      @instance << Qif::Transaction.new(:date => date, :amount => 10.0, :category => 'Credit')
      
      @buffer.should_not include('D%s' % date.strftime('%d/%m/%Y'))
      @instance.write
      @buffer.should include('D%s' % date.strftime('%d/%m/%Y'))
    end
  end
  
  describe '#close' do
    it 'should close the io stream' do
      @io.should_receive(:close)
      @instance.close
    end
  end
end
