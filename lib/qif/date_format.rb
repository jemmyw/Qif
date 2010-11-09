require 'time'

module Qif
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
      format.gsub!('yy', '%y')
      format
    end
    
    def convert_format_to_regex
      format = @format.dup
      format.gsub!('dd', '([0-3][0-9])')
      format.gsub!('mm', '([0-1][0-9])')
      format.gsub!('yyyy', '([1-2][0-9]{3})')
      format.gsub!('yy', '([0-9]{2})')
      
      /#{format}/mi
    end
  end
end
