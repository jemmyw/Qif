require 'stringio'
require 'qif/date_format'
require 'qif/transaction'

module Qif
  # The Qif::Reader class reads a qif file and provides access to
  # the transactions as Qif::Transaction objects.
  #
  # Usage:
  #
  #   reader = Qif::Reader.new(open('/path/to/qif'), 'dd/mm/yyyy')
  #   reader.each do |transaction|
  #     puts transaction.date.strftime('%d/%m/%Y')
  #     puts transaction.amount.to_s
  #   end
  class Reader
    include Enumerable
  
    SUPPORTED_ACCOUNTS = {"!Type:Bank" => "Bank account transactions",
"!Type:Cash" => "Cash account transactions",
"!Type:CCard" => "Credit card account transactions",
"!Type:Oth A" => "Asset account transactions",
"!Type:Oth L" => "Liability account transactions"}

    # Create a new Qif::Reader object. The data argument must be
    # either an IO object or a String containing the Qif file data.
    #
    # The format argument specifies the date format in the file. This
    # defaults to 'dd/mm/yyyy', but also accepts 'mm/dd/yyyy'.
    def initialize(data, format = 'dd/mm/yyyy')
      @format = DateFormat.new(format)
      @data = data.respond_to?(:read) ? data : StringIO.new(data.to_s)
      read_header
      raise("Unknown account type Should be one of followings :\n#{SUPPORTED_ACCOUNTS.keys.inspect}") unless SUPPORTED_ACCOUNTS.keys.collect(&:downcase).include? @header.downcase
      reset
    end
    
    # Return an array of Qif::Transaction objects from the Qif file. This
    # method reads the whole file before returning, so it may not be suitable
    # for very large qif files.
    def transactions
      read_all_transactions
      transaction_cache
    end
  
    # Call a block with each Qif::Transaction from the Qif file. This
    # method yields each transaction as it reads the file so it is better
    # to use this than #transactions for large qif files.
    #
    #   reader.each do |transaction|
    #     puts transaction.amount
    #   end
    def each(&block)    
      reset
    
      while transaction = next_transaction
        yield transaction
      end
    end
    
    # Return the number of transactions in the qif file.
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

    # lineno= and seek don't seem
    # to work with StringIO
    def rewind_to(n)
      @data.rewind
      while @data.lineno != n
        @data.readline
      end
    end
  
    def read_header
      headers = []
      begin
        line = @data.readline.strip
        headers << line.strip if line =~ /^!/
      end until line !~ /^!/

      @header = headers.shift
      @options = headers.map{|h| h.split(':') }.last
      
      unless line =~ /^\^/
        rewind_to @data.lineno - 1
      end
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
        record[key] = record.key?(key) ? record[key] + "\n" + line[1..-1].strip : line[1..-1].strip
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
