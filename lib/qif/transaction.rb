require 'qif/date_format'

module Qif
  # The Qif::Transaction class represents transactions in a qif file.
  class Transaction
    SUPPORTED_FIELDS = {
      :date           => {"D" => "Date"                                                              },
      :amount         => {"T" => "Amount"                                                            },
      :status         => {"C" => "Cleared status"                                                    },
      :number         => {"N" => "Num (check or reference number)"                                   },
      :payee          => {"P" => "Payee"                                                             },
      :memo           => {"M" => "Memo"                                                              },
      :adress         => {"A" => "Address (up to five lines; the sixth line is an optional message)" },
      :category       => {"L" => "Category (Category/Subcategory/Transfer/Class)"                    },
      # do we still need these? we have splits now
      :split_category => {"S" => "Category in split (Category/Transfer/Class)"                       },
      :split_memo     => {"E" => "Memo in split"                                                     },
      :split_amount   => {"$" => "Dollar amount of split"                                            },
      :end            => {"^" => "End of entry"                                                      }
    }
    DEPRECATION_FIELDS = {
      :reference   => :payee,
      :name        => :category,
      :description => :memo
    }
    SUPPORTED_FIELDS.keys.each{|s| attr_accessor s}

    attr_reader :splits
    alias :address :adress
    alias :address= :adress=

    def initialize(attributes = {})
      @splits = []
      deprecate_attributes!(attributes)
      SUPPORTED_FIELDS.keys.each{|s| instance_variable_set("@#{s.to_s}", attributes[s])}
    end

    # Returns a representation of the transaction as it
    # would appear in a qif file.
    def to_s(format = 'dd/mm/yyyy')
      SUPPORTED_FIELDS.collect do |k,v|
        next unless current = instance_variable_get("@#{k}")
        field = v.keys.first
        case current.class.to_s
        when "Time", "Date", "DateTime"
          "#{field}#{DateFormat.new(format).format(current)}"
        when "Float"
          "#{field}#{'%.2f'%current}"
        when "String"
          current.split("\n").collect {|x| "#{field}#{x}" }
        else
          "#{field}#{current}"
        end
      end.flatten.compact.join("\n")
    end

    private

    def deprecate_attributes!(attributes = {})
      attributes.select {|k,v| DEPRECATION_FIELDS.keys.include? k}.each do |key,value|
        warn("DEPRECATION WARNING : :#{key} HAS BEEN DEPRECATED IN FAVOR OF :#{DEPRECATION_FIELDS[key]} IN ORDER TO COMPLY WITH QIF SPECS.")
        attributes[DEPRECATION_FIELDS[key]] = attributes.delete(key)
      end
    end
  end
end
