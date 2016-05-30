require 'spec_helper'
require 'stringio'

describe Qif::Writer do
  let(:buffer) { "" }
  let(:io) { StringIO.new(buffer) }
  let(:instance) { Qif::Writer.new(io) }
  let(:path) { "/tmp/test" }
  
  describe '::open' do
    before do
      allow(File).to receive(:open).and_yield(io)
    end
    
    it 'should yield a Qif::Writer' do
      ran = false
      Qif::Writer.open(path) do |writer|
        ran = true
        expect(writer).to be_a(Qif::Writer)
      end
      expect(ran).to eq true
    end
    
    it 'should write the transactions' do
      date = Time.now
      
      Qif::Writer.open(path) do |writer|
        writer << Qif::Transaction.new(:date => date, :amount => 10.0, :category => 'Credit')
      end
      
      expect(buffer).to include('D%s' % date.strftime('%d/%m/%Y'))
      expect(buffer).to include('T10.0')
      expect(buffer).to include('LCredit')
    end
    
    it 'should perform a File.open on the given path' do
      expect(File).to receive(:open).with(path, 'w')
      Qif::Writer.open(path) do |writer|
      end
    end
  end

  describe '::new' do
    it 'should yield a Qif::Writer' do
      ran = false
      Qif::Writer.new(io) do |writer|
        ran = true
        expect(writer).to be_a(Qif::Writer)
      end
      expect(ran).to eq true
    end
    
    it 'should write the transactions' do
      date = Time.now
      
      Qif::Writer.new(io) do |writer|
        writer << Qif::Transaction.new(:date => date, :amount => 10.0, :category => 'Credit')
      end
      
      expect(buffer).to include('D%s' % date.strftime('%d/%m/%Y'))
      expect(buffer).to include('T10.0')
      expect(buffer).to include('LCredit')
    end
    
    it 'should perform a File.open on the given path' do
      expect(File).to receive(:open).with(path, 'w')
      Qif::Writer.open(path) do |writer|
      end
    end
  end

  describe '#write' do
    let(:date) { Time.now }

    it 'should write the header' do
      instance.write
      expect(buffer).to include("!Type:Bank\n")
    end
    
    it 'should write any pending transactions' do
      instance << Qif::Transaction.new(:date => date, :amount => 10.0, :category => 'Credit')
      
      expect(buffer).not_to include('D%s' % date.strftime('%d/%m/%Y'))
      instance.write
      expect(buffer).to include('D%s' % date.strftime('%d/%m/%Y'))
    end
  end
  
  describe '#close' do
    it 'should close the io stream' do
      expect(io).to receive(:close)
      instance.close
    end
  end
end
