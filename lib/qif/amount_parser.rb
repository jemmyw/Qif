module AmountParser
  def self.parse(amount)
    warn "= amounts are unsupported" if amount =~ /^=/ && $VERBOSE
    amount.gsub(/,/, '').gsub(/^=/, '').to_f
  end
end
