require 'stringio'
require 'qif/date_format'
require 'qif/transaction'
require 'qif/transaction/builder'
require 'qif/account'
require 'qif/account/builder'

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

    attr_reader :index
  
    SUPPORTED_ACCOUNTS = {
      "!Type:Bank" => "Bank account transactions",
      "!Type:Cash" => "Cash account transactions",
      "!Type:CCard" => "Credit card account transactions",
      "!Type:Oth A" => "Asset account transactions",
      "!Type:Oth L" => "Liability account transactions"
    }

    class UnknownAccountType < StandardError; end
    class UnrecognizedData < StandardError; end

    # Create a new Qif::Reader object. The data argument must be
    # either an IO object or a String containing the Qif file data.
    #
    # The optional format argument specifies the date format in the file. 
    # Giving a format will force it, otherwise the format will guessed 
    # reading the transactions in the file, this defaults to 'dd/mm/yyyy' 
    # if guessing method fails.
    def initialize(data, format = nil)
      @data = data.respond_to?(:read) ? data : StringIO.new(data.to_s)
      @format = DateFormat.new(format || guess_date_format || 'dd/mm/yyyy')
      read_header
      raise(UnrecognizedData, "Provided data doesn't seems to represent a QIF file") unless @header
      raise(UnknownAccountType, "Unknown account type. Should be one of followings :\n#{SUPPORTED_ACCOUNTS.keys.inspect}") unless SUPPORTED_ACCOUNTS.keys.collect(&:downcase).include? @header.downcase
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

    # Guess the file format of dates, reading the beginning of file, or return nil if no dates are found (?!).
    def guess_date_format
      begin
        line = @data.gets
        break if line.nil?

        date = line[1..-1]
        guessed_format = Qif::DateFormat::SUPPORTED_DATEFORMAT.find { |format_string, format|
          test_date_with_format?(date, format_string, format)
        }
      end until guessed_format

      @data.rewind

      guessed_format ? guessed_format.first : @fallback_format
    end

    private

    def test_date_with_format?(date, format_string, format)
      parsed_date = Date.strptime(date, format)
      if parsed_date > Date.strptime('01/01/1900', '%d/%m/%Y')
        @fallback_format ||= format_string
        parsed_date.day > 12
      end
    rescue
      false
    end
  
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
      headers
    end
  
    def read_transaction
      if transaction = read_record
        cache_transaction(transaction)
      end
    end
  
    def cache_transaction(transaction)
      transaction_cache[@index] = transaction
    end

    def read_account
      builder = Qif::Account::Builder.new
      begin
        line = @data.readline.strip
        key = line.slice!(0, 1)
        builder =
          case key
            when 'N' then builder.set_name(line)
            when 'T' then builder.set_type(line)
            when 'D' then builder.set_description(line)
            when 'L' then builder.set_limit(line)
            when '/' then builder.set_balance_date(line)
            when '$' then builder.set_balance(line)
            else builder
          end
      end until key == "^"
      builder.build
      rescue EOFError => e
        @data.close
        nil
      rescue Exception => e
        nil
    end

    def read_record
      builder = Qif::Transaction::Builder.new(->(dt){@format.parse(dt)})
      begin
        line = @data.readline.strip
        return read_account if line =~ /^\!Account/
        key = line.slice!(0, 1)
        builder =
          case key
            when 'D' then builder.set_date(line)
            when 'T' then builder.set_amount(line)
            when 'A' then builder.set_address(line)
            when 'C' then builder.set_status(line)
            when 'N' then builder.set_number(line)
            when 'P' then builder.set_payee(line)
            when 'M' then builder.set_memo(line)
            when 'L' then builder.set_category(line)
            when 'S' then builder.add_split(line)
            when 'E' then builder.set_split_memo(line)
            when '$' then builder.set_split_amount(line)
            else builder
          end
      end until key == "^"
      builder.build
      rescue EOFError => e
        @data.close
        nil
      rescue Exception => e
        nil
    end
  end
end
