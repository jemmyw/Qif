require 'time'

module Qif
  class DateFormat
    attr_reader :format

    SUPPORTED_DATEFORMAT = {
      "dd/mm/yyyy"  => "%d/%m/%Y",
      "d/mm/yyyy"   => "%d/%m/%Y",
      "dd/m/yyyy"   => "%d/%m/%Y",
      "d/m/yyyy"    => "%d/%m/%Y",

      "dd/mm/yy"    => "%d/%m/%y",
      "d/mm/yy"     => "%d/%m/%y",
      "dd/m/yy"     => "%d/%m/%y",
      "d/m/yy"      => "%d/%m/%y",

      "mm/dd/yyyy"  => "%m/%d/%Y",
      "m/dd/yyyy"   => "%m/%d/%Y",
      "mm/d/yyyy"   => "%m/%d/%Y",
      "m/d/yyyy"    => "%m/%d/%Y",

      "mm/dd/yy"    => "%m/%d/%y",
      "m/dd/yy"     => "%m/%d/%y",
      "mm/d/yy"     => "%m/%d/%y",
      "m/d/yy"      => "%m/%d/%y",
    }

    def initialize(format = 'dd/mm/yyyy')
      @format = format
    end

    def parse(date)
      Date.strptime(date, convert_format_to_strftime)
    end

    def format(date)
      date.strftime(convert_format_to_strftime)
    end

    private

    def convert_format_to_strftime
      SUPPORTED_DATEFORMAT[@format]
    end

  end
end
