require_relative "split/builder"
require_relative "builderable"
require_relative "../amount_parser"

class Qif::Transaction::Builder
  include Builderable

  def initialize(date_parser = ->(date) { Time.parse(date) })
    @txn = Qif::Transaction.new
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

  def set_adress(address)
    @txn.address = @txn.address ? @txn.address += "\n#{address}" : address
    self
  end

  alias :set_address :set_adress

  def add_split(split)
    Qif::Transaction::Split::Builder.new(self).tap do |split_builder|
      @splits << split_builder
      split_builder.set_split_category(split)
    end
  end

  def build
    @splits.each do |split_builder|
      @txn.splits << split_builder.build_split
    end
    @txn
  end

  private

  def parse_date(date)
    @date_parser.call(date)
  end
end
