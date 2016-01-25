module Builderable
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def builder_options(options)
      @options = options
    end

    def set_builder_method(attribute, massager = nil)
      options = @options || {}
      method_name = ["set", options[:prefix], attribute].compact.join("_")

      define_method(method_name) do |new_value|
        @_builder_values ||= {}

        unless massager.nil?
          if massager.kind_of?(Symbol)
            new_value = self.send(massager, new_value)
          else
            new_value = massager.call(new_value)
          end
        end

        @_builder_values[attribute] = new_value
        self
      end
    end
  end

  def _build(object)
    (@_builder_values||{}).each do |attribute, value|
      object.public_send("#{attribute}=", value)
    end

    object
  end
end
