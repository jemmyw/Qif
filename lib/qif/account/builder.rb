require_relative "../transaction/builderable"
require_relative "../amount_parser"

class Qif::Account::Builder
  include Builderable

  def initialize(date_parser = ->(date) { Time.parse(date) })
    @txn = Qif::Account.new
    @date_parser = date_parser
    @splits = []
  end

  set_builder_method :name
  set_builder_method :type
  set_builder_method :description
  set_builder_method :limit, ->(amt) { AmountParser.parse(amt) }
  set_builder_method :balance_date, :parse_date
  set_builder_method :balance, ->(amt) { AmountParser.parse(amt) }

  def build
    @txn
  end

  private

  def parse_date(date)
    @date_parser.call(date)
  end
end
