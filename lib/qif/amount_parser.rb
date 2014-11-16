module AmountParser
  def self.parse(amount)
    warn "= amounts are unsupported" if amount =~ /^=/
    amount.gsub(/,/, '').gsub(/^=/, '').to_f
  end
end