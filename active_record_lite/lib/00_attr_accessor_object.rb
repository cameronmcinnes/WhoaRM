# require "byebug"

class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |ivar_name|

      getter = "@#{ivar_name}"

      define_method(ivar_name) do
        self.instance_variable_get(getter)
      end

      setter = "#{ivar_name}="

      define_method(setter.to_sym) do |val|
        self.instance_variable_set(getter, val)
      end
    end
  end
end
