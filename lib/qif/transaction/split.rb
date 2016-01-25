class Qif::Transaction::Split
  SUPPORTED_FIELDS = {
    :category => {"S" => "Category in split (Category/Transfer/Class)" },
    :memo     => {"E" => "Memo in split"                               },
    :amount   => {"$" => "Dollar amount of split"                      },
  }

  attr_accessor :memo, :amount, :category

  # Returns a representation of the split as it
  # would appear in a qif file.
  def to_s()
    SUPPORTED_FIELDS.collect do |k,v|
      next unless current = instance_variable_get("@#{k}")
      field = v.keys.first
      case current.class.to_s
      when "Float"
        "#{field}#{'%.2f'%current}"
      when "String"
        current.split("\n").collect {|x| "#{field}#{x}" }
      else
        "#{field}#{current}"
      end
    end.flatten.compact.join("\n")
  end
end
