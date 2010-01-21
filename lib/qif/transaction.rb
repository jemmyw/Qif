require 'qif/date_format'

module Qif
  # The Qif::Transaction class represents transactions in a qif file.
  class Transaction
    attr_accessor :date, :amount, :name, :description, :reference
    
    def self.read(record) #::nodoc
      return nil unless record['D'].respond_to?(:strftime)
      
      Transaction.new(
        :date => record['D'],
        :amount => record['T'].to_f, 
        :name => record['L'], 
        :description => record['M'],
        :reference => record['P']
      )
    end
    
    def initialize(attributes = {})
      @date = attributes[:date]
      @amount = attributes[:amount]
      @name = attributes[:name]
      @description = attributes[:description]
      @reference = attributes[:reference]
    end
    
    # Returns a representation of the transaction as it
    # would appear in a qif file.
    def to_s(format = 'dd/mm/yyyy')
      {
        'D' => DateFormat.new(format).format(date),
        'T' => '%.2f' % amount,
        'L' => name,
        'M' => description,
        'P' => reference
      }.map{|k,v| "#{k}#{v}" }.join("\n")
    end
  end
end
