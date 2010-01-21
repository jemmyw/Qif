require 'stringio'
require 'qif/date_format'
require 'qif/transaction'

module Qif
  class Reader
    include Enumerable
  
    def initialize(data, format = 'dd/mm/yyyy')
      @format = DateFormat.new(format)
      @data = data.respond_to?(:read) ? data : StringIO.new(data.to_s)
      read_header
      reset
    end
    
    def transactions
      read_all_transactions
      transaction_cache
    end
  
    def each(&block)    
      reset
    
      while transaction = next_transaction
        yield transaction
      end
    end
    
    def size
      read_all_transactions
      transaction_cache.size
    end
    alias length size
  
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
        cache_transaction(transaction) if transaction
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
      @data.close
      nil
    rescue Exception => e
      nil
    end
  end
end
