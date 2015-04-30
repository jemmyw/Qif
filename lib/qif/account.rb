require 'qif/date_format'

module Qif
  # The Qif::Account class represents an account in a qif file.
  class Account
    SUPPORTED_FIELDS = {
      :name           => {"N" => "Name"                                                              },
      :type           => {"T" => "Type"                                                              },
      :description    => {"D"=> "Description"                                                        },
      :limit          => {"L" => "Credit Limit (if applicable)"                                      },
      :balance_date   => {"/" => "Statement balance date"                                            },
      :balance        => {"\$" => "Statement balance",                                                },
      :end            => {"^" => "End of entry"                                                      }
    }

    SUPPORTED_FIELDS.keys.each{|s| attr_accessor s}

    def initialize(attributes = {})
      SUPPORTED_FIELDS.keys.each{|s| instance_variable_set("@#{s.to_s}", attributes[s])}
    end

    # Returns a representation of the account as it
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
      end.flatten.compact.unshift('!Account').join("\n")
    end

    private
  end
end
