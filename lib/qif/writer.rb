require 'qif/date_format'
require 'qif/transaction'

module Qif
  # The Qif::Writer class takes Qif::Transaction objects and outputs
  # a Qif file.
  #
  # Usage:
  #   Qif::Writer.open('/path/to/new/qif') do |writer|
  #     writer << Qif::Transaction.new(
  #       :date => Time.now, 
  #       :amount => 10.0, 
  #       :name => 'Credit'
  #     )
  #   end
  class Writer
    attr_accessor :type, :format
    
    # Open a qif file for writing and yield a Qif::Writer instance.
    # For parameters see #new.
    def self.open(path, type = 'Bank', format = 'dd/mm/yyyy', &block)
      File.open(path, 'w') do |file|
        self.new(file, type, format, &block)
      end
    end
    
    # Create a new Qif::Writer. Expects an IO object or a filepath.
    # Can optionally take a block which will yield the writer and
    # automatically call write afterwards.
    #
    # Parameters:
    #
    # * <tt>io</tt> - An IO object or filepath
    # * <tt>type</tt> - Used to write the header, defaults to 'Bank'
    # * <tt>format</tt> - The format of dates in the qif file, defaults to 'dd/mm/yyyy'. Also accepts 'mm/dd/yyyy'
    #
    # Usage:
    #   buffer = StringIO.new
    #   writer = Qif::Writer.new(buffer)
    #   writer << Qif::Transaction.new(:date => Time.now, :amount => 10.0, :name => 'Credit')
    #   writer.write
    #   puts buffer
    #
    # Usage with block:
    #   buffer = StringIO.new
    #   Qif::Writer.new(buffer) do |writer|
    #     writer << Qif::Transaction.new(:date => Time.now, :amount => 10.0, :name => 'Credit')
    #   end
    #   puts buffer
    def initialize(io, type = 'Bank', format = 'dd/mm/yyyy')
      @io = io.respond_to?(:write) ? io : File.open(io, 'w')
      @type = type
      @format = format
      @transactions = []
      @accounts = []
      
      if block_given?
        yield self
        self.write
      end
    end
    
    # Add a transaction for writing
    def <<(transaction)
      case transaction.class.to_s
      when "Qif::Transaction"
        @transactions << transaction
      when "Qif::Account"
        @accounts << transaction
      end  
    end
    
    # Write the qif file
    def write
      write_account
      write_header
      write_transactions
    end
    
    # Close the qif file
    def close
      @io.close
    end
    
    private
    
    def write_header
      @io.write("!Type:%s\n" % @type)
    end

    def write_account
      write_record(@accounts.first.to_s) # only one account per file
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
end
