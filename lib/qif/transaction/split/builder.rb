require_relative '../builderable'
require_relative '../split'

#
# Factory class for buliding splits. Do not construct this directly, rather use
# Qif::Transaction::Builder#add_split
#
class Qif::Transaction::Split::Builder
  include Builderable

  def initialize(transaction_builder)
    @transaction_builder = transaction_builder
    yield self if block_given?
  end

  def add_split(split_memo)
    @transaction_builder.add_split(split_memo)
  end

  builder_options prefix: 'split'
  set_builder_method :memo
  set_builder_method :amount, ->(amt) { AmountParser.parse(amt) }
  set_builder_method :category

  def build_split
    _build(Qif::Transaction::Split.new)
  end

  def method_missing(name, *args, &block)
    @transaction_builder.send(name, *args, &block)
  end
end
