require 'spec_helper'

describe Qif::DateFormat do
  it 'should work with 2 digit years in mm/dd/yy format' do
    reader = Qif::DateFormat.new('mm/dd/yy')
    time = reader.parse('09/28/10')
    expect(time).to eq(Date.strptime('09/28/10', '%m/%d/%y'))
		time = reader.parse('09/28/94')
		expect(time).to eq(Date.strptime('09/28/94', '%m/%d/%y'))
  end

  it 'should work with 2 digit years in dd/mm/yy format' do
    reader = Qif::DateFormat.new('dd/mm/yy')
    time = reader.parse('28/09/10')
    expect(time).to eq(Date.strptime('28/09/10', '%d/%m/%y'))
		time = reader.parse('28/09/94')
		expect(time).to eq(Date.strptime('28/09/94', '%d/%m/%y'))
  end
end
