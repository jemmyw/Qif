require_relative "split/builder"
require_relative "builderable"
require_relative "../amount_parser"

#
# Factory class for building transactions.
#
# @usage
# txn = Qif::Transaction::Builder.new
#   .set_date('10/06/1983')
#   .set_amount('-10.0')
#   .set_memo('debit $10')
#   .add_split('jules')
#   .set_split_memo('half to jules')
#   .add_split_amount('-5.0')
#   .build
#
class Qif::Transaction::Builder
  include Builderable

  def initialize(date_parser = ->(date) { Time.parse(date) })
    @date_parser = date_parser
    @splits = []
  end

  set_builder_method :date, :parse_date
  set_builder_method :amount, ->(amt) { AmountParser.parse(amt) }
  set_builder_method :status
  set_builder_method :number
  set_builder_method :payee
  set_builder_method :memo
  set_builder_method :category

  def set_address(address)
    @address = [@address, address].compact.join("\n")
    self
  end
  alias :set_adress :set_address

  def add_split(split)
    Qif::Transaction::Split::Builder.new(self).set_split_category(split).tap do |builder|
      @splits << builder
    end
  end

  def build
    _build(Qif::Transaction.new).tap do |txn|
      txn.address = @address

      @splits.each do |split_builder|
        txn.add_split(split_builder.build_split)
      end
    end
  end

  private

  def parse_date(date)
    @date_parser.call(date)
  end
end
