require 'time'

module Qif
  class DateFormat
    attr_reader :conversion_format

    def initialize(format = 'dd/mm/yyyy')
      @conversion_format = format
    end

    def parse(date)
      regex = convert_format_to_regex
      order = date_order

      if match = regex.match(date)
        year = match[order.index('y')+1].to_i

        if year < 100
          start_year = Time.now.year - 50
          start_cent = (start_year/100).to_i*100
          if year > start_year-start_cent
            year += start_cent
          else
            year += ((Time.now.year/100).to_i*100)
          end
        end

        Time.mktime(year, *%w(m d).map{|t| match[order.index(t) + 1].to_i })
      end
    end

    def format(date)
      date.strftime(convert_format_to_strftime)
    end

    private

    def date_order
      %w(d m y).sort{|a,b| @conversion_format.index(a) <=> @conversion_format.index(b) }
    end

    def convert_format_to_strftime
      format = @conversion_format.dup
      format.gsub!(/d{1,2}/, '%d')
      format.gsub!(/m{1,2}/, '%m')
      format.gsub!('yyyy', '%Y')
      format.gsub!('yy', '%y')
      format
    end

    def convert_format_to_regex
      format = @conversion_format.dup
      format.gsub!('dd'   , '([0-3][0-9])')
      format.gsub!('d'    , '([0-3]?[0-9])')
      format.gsub!('mm'   , '([0-1][0-9])')
      format.gsub!('m'    , '([0-1]?[0-9])')
      format.gsub!('yyyy' , '([1-2][0-9]{3})')
      format.gsub!('yy'   , '([0-9]{2})')

      /#{format}/mi
    end
  end
end
