shared_context 'builder method' do |attribute, input, method = nil, expected = nil|
  expected = input if expected.nil?
  method = "set_#{attribute}" if method.nil?

  it 'and set the #{attribute} on the transaction' do
    builder.send(method, input)
    expect(do_build.send(attribute)).to eq(expected)
  end

  it 'and return the builder' do
    expect(builder.send(method, input)).to be_kind_of described_class
  end
end

