require 'stringio'
require 'time'

module Qif
  class Reader
    include Enumerable
  
    def initialize(data, format = 'dd/mm/yyyy')
      @format = DateFormat.new(format)
      @data = data.respond_to?(:read) ? data : StringIO.new(data.to_s)
      read_header
    end
  
    def each(&block)    
      reset
    
      while transaction = next_transaction
        yield transaction
      end
    end
  
    private
  
    def read_all_transactions
      while next_transaction; end
    end
  
    def transaction_cache
      @transaction_cache ||= []
    end
  
    def reset
      @index = -1
    end
  
    def next_transaction
      @index += 1
    
      if transaction = transaction_cache[@index]
        transaction
      else
        read_transaction
      end
    end
  
    def read_header
      @header = read_record
    end
  
    def read_transaction
      if record = read_record
        transaction = Transaction.read(record)
        cache_transaction(transaction)
      else
        nil
      end
    end
  
    def cache_transaction(transaction)
      transaction_cache[@index] = transaction
    end

    def read_record
      record = {}

      begin
        line = @data.readline
        key = line[0,1]

        record[key] = line[1..-1].strip
        
        if date = @format.parse(record[key])
          record[key] = date
        end
      end until line =~ /^\^/
      
      record
    rescue EOFError => e
      nil
    end
  end
  
  class Writer
    attr_accessor :type, :format
    
    def self.open(path, type = 'Bank', format = 'dd/mm/yyyy')
      File.open(path, 'w') do |file|
        writer = self.new(file, type, format)
        yield writer
        writer.write
      end
    end
    
    def initialize(io, type = 'Bank', format = 'dd/mm/yyyy')
      @io = io.respond_to?(:write) ? io : File.open(io, 'w')
      @type = type
      @format = format
      @transactions = []
    end
    
    def <<(transaction)
      @transactions << transaction
    end
    
    def write
      write_header
      write_transactions
    end
    
    def close
      @io.close
    end
    
    def write_header
      write_record('!Type:%s' % @type)
    end
    
    def write_transactions
      @transactions.each do |t|
        write_transaction(t)
      end
    end
    
    def write_transaction(transaction)
      write_record(transaction.to_s(@format))
    end
    
    def write_record(data)
      @io.write(data)
      @io.write("\n^\n")
    end
  end
  
  class DateFormat
    attr_reader :format
    
    def initialize(format = 'dd/mm/yyyy')
      @format = format
    end
    
    def parse(date)
      regex = convert_format_to_regex
      order = date_order
      
      if match = regex.match(date)
        Time.mktime(*%w(y m d).map{|t| match[order.index(t) + 1].to_i })
      end
    end
    
    def format(date)
      date.strftime(convert_format_to_strftime)
    end
    
    private
    
    def date_order
      %w(d m y).sort{|a,b| @format.index(a) <=> @format.index(b) }
    end
    
    def convert_format_to_strftime
      format = @format.dup
      format.gsub!('dd', '%d')
      format.gsub!('mm', '%m')
      format.gsub!('yyyy', '%Y')
      format
    end
    
    def convert_format_to_regex
      format = @format.dup
      format.gsub!('dd', '([0-3][0-9])')
      format.gsub!('mm', '([0-1][0-12])')
      format.gsub!('yyyy', '([1-2][0-9]{3})')
      
      /#{format}/mi
    end
  end
  
  class Transaction
    attr_accessor :date, :amount, :name, :description
    
    def self.read(record)
      Transaction.new(
        :date => record['D'],
        :amount => record['T'].to_f, 
        :name => record['L'], 
        :description => record['M']
      )
    end
    
    def initialize(attributes = {})
      @date = attributes[:date]
      @amount = attributes[:amount]
      @name = attributes[:name]
      @description = attributes[:description]
    end
    
    def to_s(format = 'dd/mm/yyyy')
      {
        'D' => DateFormat.new(format).format(date),
        'T' => amount.to_s,
        'L' => name,
        'M' => description
      }.map{|k,v| "#{k}#{v}" }.join("\n")
    end
  end
end
