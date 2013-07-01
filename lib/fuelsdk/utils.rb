module FuelSDK
  module_function
    def format_name_value_pairs attributes
      attrs = []
      attributes.each do |name, value|
        attrs.push 'Name' => name, 'Value' => value
      end

      attrs
    end
end
