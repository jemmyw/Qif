require 'spec/spec_helper'

describe Qif::DateFormat do
  it 'should work with 2 digit years in mm/dd/yy format' do
    reader = Qif::DateFormat.new('mm/dd/yy')
    time = reader.parse('09/28/10')
    time.should == Time.mktime(2010, 9, 28)
  end

  it 'should work with 2 digit years in dd/mm/yy format' do
    reader = Qif::DateFormat.new('dd/mm/yy')
    time = reader.parse('28/09/10')
    time.should == Time.mktime(2010, 9, 28)
  end
end