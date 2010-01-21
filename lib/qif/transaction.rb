require 'qif/date_format'

module Qif
  class Transaction
    attr_accessor :date, :amount, :name, :description, :reference
    
    def self.read(record)
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
