require 'spec_helper'

describe Qif::DateFormat do
  it 'should work with 2 digit years in mm/dd/yy format' do
    reader = Qif::DateFormat.new('mm/dd/yy')
    time = reader.parse('09/28/10')
    time.should == Time.mktime(2010, 9, 28)
    time = reader.parse('09/28/94')
    time.should == Time.mktime(1994, 9, 28)
  end

  it 'should work with 2 digit years in dd/mm/yy format' do
    reader = Qif::DateFormat.new('dd/mm/yy')
    time = reader.parse('28/09/10')
    time.should == Time.mktime(2010, 9, 28)
    time = reader.parse('28/09/94')
    time.should == Time.mktime(1994, 9, 28)
  end

  it 'should work with 1 digit day in d/mm/yy format' do
    reader = Qif::DateFormat.new('d/mm/yy')
    time = reader.parse('8/09/10')
    time.should == Time.mktime(2010, 9, 8)
  end

  it 'should work with 1 digit month in dd/m/yy format' do
    reader = Qif::DateFormat.new('dd/m/yy')
    time = reader.parse('18/9/10')
    time.should == Time.mktime(2010, 9, 18)
  end
end
